# frozen_string_literal: true

module Checkoff
  # Base class to evaluate a task selector function given fully evaluated arguments
  class FunctionEvaluator
    def initialize(task_selector:,
                   tasks:)
      @task_selector = task_selector
      @tasks = tasks
    end

    def evaluate_arg?(_index)
      true
    end

    private

    def fn?(object, fn_name)
      object.is_a?(Array) && !object.empty? && [fn_name, fn_name.to_s].include?(object[0])
    end

    def pull_custom_field_or_raise(task, custom_field_gid)
      custom_fields = task.custom_fields
      if custom_fields.nil?
        raise "Could not find custom_fields under task (was 'custom_fields' included in 'extra_fields'?)"
      end

      matched_custom_field = custom_fields.find { |data| data.fetch('gid') == custom_field_gid }
      if matched_custom_field.nil?
        raise "Could not find custom field with gid #{custom_field_gid} " \
              "in task #{task.gid} with custom fields #{custom_fields}"
      end

      matched_custom_field
    end

    attr_reader :task_selector

    def pull_enum_values(custom_field)
      resource_subtype = custom_field.fetch('resource_subtype')
      case resource_subtype
      when 'enum'
        [custom_field.fetch('enum_value')]
      when 'multi_enum'
        custom_field.fetch('multi_enum_values')
      else
        raise "Teach me how to handle resource_subtype #{resource_subtype}"
      end
    end

    def find_gids(custom_field, enum_value)
      if enum_value.nil?
        []
      else
        raise "Unexpected enabled value on custom field: #{custom_field}" if enum_value.fetch('enabled') == false

        [enum_value.fetch('gid')]
      end
    end

    def pull_custom_field_values_gids(task, custom_field_gid)
      custom_field = pull_custom_field_or_raise(task, custom_field_gid)
      pull_enum_values(custom_field).flat_map do |enum_value|
        find_gids(custom_field, enum_value)
      end
    end
  end

  # :and function
  class AndFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :and)
    end

    def evaluate(_task, lhs, rhs)
      lhs && rhs
    end
  end

  # :not function
  class NotFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :not)
    end

    def evaluate(_task, subvalue)
      !subvalue
    end
  end

  # :nil? function
  class NilPFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :nil?)
    end

    def evaluate(_task, subvalue)
      subvalue.nil?
    end
  end

  # :tag function
  class TagPFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :tag)
    end

    def evaluate_arg?(_index)
      false
    end

    def evaluate(task, tag_name)
      task.tags.map(&:name).include? tag_name
    end
  end

  # :due function
  class DuePFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :due)
    end

    def evaluate(task)
      @tasks.task_ready?(task)
    end
  end

  # :custom_field_value function
  class CustomFieldValueFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :custom_field_value)
    end

    def evaluate_arg?(_index)
      false
    end

    def evaluate(task, custom_field_name)
      custom_fields = task.custom_fields
      if custom_fields.nil?
        raise "custom fields not found on task - did you add 'custom_field' in your extra_fields argument?"
      end

      custom_field = custom_fields.find { |field| field.fetch('name') == custom_field_name }
      return nil if custom_field.nil?

      custom_field['display_value']
    end
  end

  # :custom_field_gid_value function
  class CustomFieldGidValueFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :custom_field_gid_value)
    end

    def evaluate_arg?(_index)
      false
    end

    def evaluate(task, custom_field_gid)
      custom_field = pull_custom_field_or_raise(task, custom_field_gid)
      custom_field['display_value']
    end
  end

  # :custom_field_gid_value_contains_any_gid function
  class CustomFieldGidValueContainsAnyGidFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :custom_field_gid_value_contains_any_gid)
    end

    def evaluate_arg?(_index)
      false
    end

    def evaluate(task, custom_field_gid, custom_field_values_gids)
      actual_custom_field_values_gids = pull_custom_field_values_gids(task, custom_field_gid)

      actual_custom_field_values_gids.any? do |custom_field_value|
        custom_field_values_gids.include?(custom_field_value)
      end
    end
  end

  # :custom_field_gid_value_contains_all_gids function
  class CustomFieldGidValueContainsAllGidsFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :custom_field_gid_value_contains_all_gids)
    end

    def evaluate_arg?(_index)
      false
    end

    def evaluate(task, custom_field_gid, custom_field_values_gids)
      actual_custom_field_values_gids = pull_custom_field_values_gids(task, custom_field_gid)

      custom_field_values_gids.all? do |custom_field_value|
        actual_custom_field_values_gids.include?(custom_field_value)
      end
    end
  end

  # Evaluator task selectors against a task
  class TaskSelectorEvaluator
    def initialize(task:,
                   tasks: Checkoff::Tasks.new)
      @task = task
      @tasks = tasks
    end

    FUNCTION_EVALUTORS = [
      NotFunctionEvaluator,
      NilPFunctionEvaluator,
      TagPFunctionEvaluator,
      CustomFieldValueFunctionEvaluator,
      CustomFieldGidValueFunctionEvaluator,
      CustomFieldGidValueContainsAnyGidFunctionEvaluator,
      CustomFieldGidValueContainsAllGidsFunctionEvaluator,
      AndFunctionEvaluator,
      DuePFunctionEvaluator,
    ].freeze

    def evaluate(task_selector)
      return true if task_selector == []

      FUNCTION_EVALUTORS.each do |evaluator_class|
        evaluator = evaluator_class.new(task_selector: task_selector,
                                        tasks: tasks)

        next unless evaluator.matches?

        return try_this_evaluator(task_selector, evaluator)
      end

      raise "Syntax issue trying to handle #{task_selector}"
    end

    private

    def try_this_evaluator(task_selector, evaluator)
      evaluated_args = task_selector[1..].map.with_index do |item, index|
        if evaluator.evaluate_arg?(index)
          evaluate(item)
        else
          item
        end
      end

      evaluator.evaluate(task, *evaluated_args)
    end

    attr_reader :task, :tasks, :task_selector
  end
end
