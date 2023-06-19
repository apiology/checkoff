# frozen_string_literal: true

module Checkoff
  # Base class to evaluate a task selector function given fully evaluated arguments
  class FunctionEvaluator
    # @param task_selector [Array<(Symbol, Array)>]
    # @param tasks [Checkoff::Tasks]
    def initialize(task_selector:,
                   tasks:)
      @task_selector = task_selector
      @tasks = tasks
    end

    # @sg-ignore
    # @param _index [Integer]
    def evaluate_arg?(_index)
      true
    end

    # @sg-ignore
    # @return [Boolean]
    def matches?
      raise 'Override me!'
    end

    private

    # @param object [Object]
    # @param fn_name [Symbol]
    def fn?(object, fn_name)
      object.is_a?(Array) && !object.empty? && [fn_name, fn_name.to_s].include?(object[0])
    end

    # @sg-ignore
    # @param task [Asana::Resources::Task]
    # @param custom_field_gid [String]
    # @return [Hash]
    def pull_custom_field_or_raise(task, custom_field_gid)
      # @type [Array<Hash>]
      custom_fields = task.custom_fields
      if custom_fields.nil?
        raise "Could not find custom_fields under task (was 'custom_fields' included in 'extra_fields'?)"
      end

      # @sg-ignore
      # @type [Hash, nil]
      matched_custom_field = custom_fields.find { |data| data.fetch('gid') == custom_field_gid }
      if matched_custom_field.nil?
        raise "Could not find custom field with gid #{custom_field_gid} " \
              "in task #{task.gid} with custom fields #{custom_fields}"
      end

      matched_custom_field
    end

    # @return [Array<(Symbol, Array)>]
    attr_reader :task_selector

    # @sg-ignore
    # @param custom_field [Hash]
    # @return [Array<String>]
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

    # @param custom_field [Hash]
    # @param enum_value [Object, nil]
    # @return [Array<String>]
    def find_gids(custom_field, enum_value)
      if enum_value.nil?
        []
      else
        raise "Unexpected enabled value on custom field: #{custom_field}" if enum_value.fetch('enabled') == false

        [enum_value.fetch('gid')]
      end
    end

    # @param task [Asana::Resources::Task]
    # @param custom_field_gid [String]
    # @return [Array<String>]
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

    # @param _task [Asana::Resources::Task]
    # @param lhs [Object]
    # @param rhs [Object]
    # @return [Object]
    def evaluate(_task, lhs, rhs)
      lhs && rhs
    end
  end

  # :not function
  class NotFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :not)
    end

    # @param _task [Asana::Resources::Task]
    # @param subvalue [Object]
    # @return [Boolean]
    def evaluate(_task, subvalue)
      !subvalue
    end
  end

  # :nil? function
  class NilPFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :nil?)
    end

    # @param _task [Asana::Resources::Task]
    # @param subvalue [Object]
    # @return [Boolean]
    def evaluate(_task, subvalue)
      subvalue.nil?
    end
  end

  # :tag function
  class TagPFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :tag)
    end

    # @param _index [Integer]
    def evaluate_arg?(_index)
      false
    end

    # @sg-ignore
    # @param task [Asana::Resources::Task]
    # @param tag_name [String]
    # @return [Boolean]
    def evaluate(task, tag_name)
      task.tags.map(&:name).include? tag_name
    end
  end

  # :due function
  class DuePFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :due)
    end

    # @param task [Asana::Resources::Task]
    # @return [Boolean]
    def evaluate(task)
      @tasks.task_ready?(task)
    end
  end

  # :due_date_set function
  class DueDateSetPFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :due_date_set)
    end

    # @sg-ignore
    # @param task [Asana::Resources::Task]
    # @return [Boolean]
    def evaluate(task)
      !task.due_at.nil? || !task.due_on.nil?
    end
  end

  # :custom_field_value function
  class CustomFieldValueFunctionEvaluator < FunctionEvaluator
    def matches?
      fn?(task_selector, :custom_field_value)
    end

    # @param _index [Integer]
    def evaluate_arg?(_index)
      false
    end

    # @param task [Asana::Resources::Task]
    # @param custom_field_name [String]
    # @return [String, nil]
    def evaluate(task, custom_field_name)
      custom_fields = task.custom_fields
      if custom_fields.nil?
        raise "custom fields not found on task - did you add 'custom_field' in your extra_fields argument?"
      end

      # @sg-ignore
      # @type [Hash, nil]
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

    # @sg-ignore
    # @param task [Asana::Resources::Task]
    # @param custom_field_gid [String]
    # @return [String, nil]
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

    # @param task [Asana::Resources::Task]
    # @param custom_field_gid [String]
    # @param custom_field_values_gids [Array<String>]
    # @return [Boolean]
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

    # @param task [Asana::Resources::Task]
    # @param custom_field_gid [String]
    # @param custom_field_values_gids [Array<String>]
    # @return [Boolean]
    def evaluate(task, custom_field_gid, custom_field_values_gids)
      actual_custom_field_values_gids = pull_custom_field_values_gids(task, custom_field_gid)

      custom_field_values_gids.all? do |custom_field_value|
        actual_custom_field_values_gids.include?(custom_field_value)
      end
    end
  end

  # Evaluator task selectors against a task
  class TaskSelectorEvaluator
    # @param task [Asana::Resources::Task]
    # @param tasks [Checkoff::Tasks]
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
      DueDateSetPFunctionEvaluator,
    ].freeze

    # @param task_selector [Array]
    # @return [Boolean, Object, nil]
    def evaluate(task_selector)
      return true if task_selector.empty?

      # @param evaluator_class [Class<FunctionEvaluator>]
      FUNCTION_EVALUTORS.each do |evaluator_class|
        # @sg-ignore
        # @type [FunctionEvaluator]
        evaluator = evaluator_class.new(task_selector: task_selector,
                                        tasks: tasks)

        next unless evaluator.matches?

        return try_this_evaluator(task_selector, evaluator)
      end

      raise "Syntax issue trying to handle #{task_selector.inspect}"
    end

    private

    # @sg-ignore
    # @param task_selector [Array]
    # @param evaluator [FunctionEvaluator]
    # @return [Boolean, Object, nil]
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

    # @return [Asana::Resources::Task]
    attr_reader :task
    # @return [Checkoff::Tasks]
    attr_reader :tasks
    # @return [Array<(Symbol, Array)>]
    attr_reader :task_selector
  end
end
