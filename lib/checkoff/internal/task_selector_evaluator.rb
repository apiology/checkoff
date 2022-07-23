# frozen_string_literal: true

module Checkoff
  # Base class to evaluate a task selector function given fully evaluated arguments
  class FunctionEvaluator
    def initialize(task_selector:)
      @task_selector = task_selector
    end

    def evaluate_arg?(_index)
      true
    end

    private

    def fn?(object, fn_name)
      object.is_a?(Array) && !object.empty? && [fn_name, fn_name.to_s].include?(object[0])
    end

    attr_reader :task_selector
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

      (custom_field_values_gids - actual_custom_field_values_gids).empty?
    end

    private

    def pull_custom_field_or_raise(task, custom_field_gid)
      custom_fields = task.custom_fields
      if custom_fields.nil?
        raise "Could not find custom_fields under task (was 'custom_fields' included in 'extra_fields'?)"
      end

      matched_custom_field = custom_fields.find { |data| data.fetch('gid') == custom_field_gid }
      raise "Could not find custom field with gid #{custom_field_gid}" if matched_custom_field.nil?

      matched_custom_field
    end

    def pull_custom_field_values_gids(task, custom_field_gid)
      matched_custom_field = pull_custom_field_or_raise(task, custom_field_gid)

      enum_value = matched_custom_field.fetch('enum_value')
      actual_custom_field_values_gids = []
      unless enum_value.nil?
        if enum_value.fetch('enabled') == false
          raise "Unexpected enabled value on custom field: #{matched_custom_field}"
        end

        actual_custom_field_values_gids = [enum_value.fetch('gid')]
      end
      actual_custom_field_values_gids
    end
  end

  # Evaluator task selectors against a task
  class TaskSelectorEvaluator
    def initialize(task:)
      @task = task
    end

    FUNCTION_EVALUTORS = [
      NotFunctionEvaluator,
      NilPFunctionEvaluator,
      TagPFunctionEvaluator,
      CustomFieldValueFunctionEvaluator,
      CustomFieldGidValueContainsAnyGidFunctionEvaluator,
    ].freeze

    def evaluate(task_selector)
      return true if task_selector == []

      FUNCTION_EVALUTORS.each do |evaluator_class|
        evaluator = evaluator_class.new(task_selector: task_selector)

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

    attr_reader :task, :task_selector
  end
end