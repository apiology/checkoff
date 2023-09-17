# frozen_string_literal: true

module Checkoff
  module TaskSelectorClasses
    # Base class to evaluate a task selector function given fully evaluated arguments
    class FunctionEvaluator
      # @param task_selector [Array<(Symbol, Array)>,String]
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

      # @param task [Asana::Resources::Task]
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, nil]
      def pull_date_field_by_name_or_raise(task, field_name)
        if field_name == :modified
          return Time.parse(task.modified_at).to_date unless task.modified_at.nil?

          return nil
        end

        if field_name == :due
          return Time.parse(task.due_at).to_date unless task.due_at.nil?

          return Date.parse(task.due_on) unless task.due_on.nil?

          return nil
        end

        raise "Teach me how to handle field #{field_name}"
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

      # @sg-ignore
      # @param task [Asana::Resources::Task]
      # @param custom_field_name [String]
      # @return [Hash, nil]
      def pull_custom_field_by_name(task, custom_field_name)
        custom_fields = task.custom_fields
        if custom_fields.nil?
          raise "custom fields not found on task - did you add 'custom_fields' in your extra_fields argument?"
        end

        # @sg-ignore
        # @type [Hash, nil]
        custom_fields.find { |field| field.fetch('name') == custom_field_name }
      end

      # @param task [Asana::Resources::Task]
      # @param custom_field_name [String]
      # @return [Hash]
      def pull_custom_field_by_name_or_raise(task, custom_field_name)
        custom_field = pull_custom_field_by_name(task, custom_field_name)
        if custom_field.nil?
          raise "Could not find custom field with name #{custom_field_name} " \
                "in task #{task.gid} with custom fields #{task.custom_fields}"
        end
        custom_field
      end
    end

    # :and function
    class AndFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :and

      def matches?
        fn?(task_selector, FUNCTION_NAME)
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
      FUNCTION_NAME = :not

      def matches?
        fn?(task_selector, FUNCTION_NAME)
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

    # :equals? function
    class EqualsPFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :equals?

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      # @param _task [Asana::Resources::Task]
      # @param lhs [Object]
      # @param rhs [Object]
      # @return [Boolean]
      def evaluate(_task, lhs, rhs)
        lhs == rhs
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

    # :unassigned function
    class UnassignedPFunctionEvaluator < FunctionEvaluator
      def matches?
        fn?(task_selector, :unassigned)
      end

      # @param task [Asana::Resources::Task]
      # @return [Boolean]
      def evaluate(task)
        task.assignee.nil?
      end
    end

    # :due_date_set function
    class DueDateSetPFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :due_date_set

      def matches?
        fn?(task_selector, FUNCTION_NAME)
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
      FUNCTION_NAME = :custom_field_value

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      # @param _index [Integer]
      def evaluate_arg?(_index)
        false
      end

      # @param task [Asana::Resources::Task]
      # @param custom_field_name [String]
      # @return [String, nil]
      def evaluate(task, custom_field_name)
        custom_field = pull_custom_field_by_name(task, custom_field_name)
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
      FUNCTION_NAME = :custom_field_gid_value_contains_any_gid

      def matches?
        fn?(task_selector, FUNCTION_NAME)
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
      FUNCTION_NAME = :custom_field_gid_value_contains_all_gids

      def matches?
        fn?(task_selector, FUNCTION_NAME)
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

    # :field_less_than_n_days_ago
    class FieldLessThanNDaysAgoFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :field_less_than_n_days_ago

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      def evaluate_arg?(_index)
        false
      end

      # @param task [Asana::Resources::Task]
      # @param field_name [Symbol]
      # @param num_days [Integer]
      #
      # @return [Boolean]
      def evaluate(task, field_name, num_days)
        date = pull_date_field_by_name_or_raise(task, field_name)

        return false if date.nil?

        # @sg-ignore
        n_days_ago = Date.today - num_days
        # @sg-ignore
        date < n_days_ago
      end
    end

    # :field_greater_than_or_equal_to_n_days_from_today
    class FieldGreaterThanOrEqualToNDaysFromTodayFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :field_greater_than_or_equal_to_n_days_from_today

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      def evaluate_arg?(_index)
        false
      end

      # @param task [Asana::Resources::Task]
      # @param field_name [Symbol]
      # @param num_days [Integer]
      #
      # @return [Boolean]
      def evaluate(task, field_name, num_days)
        date = pull_date_field_by_name_or_raise(task, field_name)

        return false if date.nil?

        # @sg-ignore
        n_days_from_today = Date.today + num_days
        # @sg-ignore
        date >= n_days_from_today
      end
    end

    # :custom_field_less_than_n_days_from_now function
    class CustomFieldLessThanNDaysFromNowFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :custom_field_less_than_n_days_from_now

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      def evaluate_arg?(_index)
        false
      end

      # @param task [Asana::Resources::Task]
      # @param custom_field_name [String]
      # @param num_days [Integer]
      # @return [Boolean]
      def evaluate(task, custom_field_name, num_days)
        custom_field = pull_custom_field_by_name_or_raise(task, custom_field_name)

        # @sg-ignore
        # @type [String, nil]
        time_str = custom_field.fetch('display_value')
        return false if time_str.nil?

        time = Time.parse(time_str)
        n_days_from_now = (Time.now + (num_days * 24 * 60 * 60))
        time < n_days_from_now
      end
    end

    # :custom_field_greater_than_or_equal_to_n_days_from_now function
    class CustomFieldGreaterThanOrEqualToNDaysFromNowFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :custom_field_greater_than_or_equal_to_n_days_from_now

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      def evaluate_arg?(_index)
        false
      end

      # @param task [Asana::Resources::Task]
      # @param custom_field_name [String]
      # @param num_days [Integer]
      # @return [Boolean]
      def evaluate(task, custom_field_name, num_days)
        custom_field = pull_custom_field_by_name_or_raise(task, custom_field_name)

        # @sg-ignore
        # @type [String, nil]
        time_str = custom_field.fetch('display_value')
        return false if time_str.nil?

        time = Time.parse(time_str)
        n_days_from_now = (Time.now + (num_days * 24 * 60 * 60))
        time >= n_days_from_now
      end
    end

    # :last_story_created_less_than_n_days_ago function
    class LastStoryCreatedLessThanNDaysAgoFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :last_story_created_less_than_n_days_ago

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      def evaluate_arg?(_index)
        false
      end

      # @param task [Asana::Resources::Task]
      # @param num_days [Integer]
      # @param excluding_resource_subtypes [Array<String>]
      # @return [Boolean]
      def evaluate(task, num_days, excluding_resource_subtypes)
        # @type [Enumerable<Asana::Resources::Story>]

        # for whatever reason, .last on the enumerable does not impose ordering; .to_a does!

        # @type [Array<Asana::Resources::Story>]
        stories = task.stories.to_a.reject do |story|
          excluding_resource_subtypes.include? story.resource_subtype
        end
        return true if stories.empty? # no stories == infinitely old!

        last_story = stories.last
        last_story_created_at = Time.parse(last_story.created_at)
        n_days_ago = Time.now - (num_days * 24 * 60 * 60)
        last_story_created_at < n_days_ago
      end
    end

    # String literals
    class StringLiteralEvaluator < FunctionEvaluator
      def matches?
        task_selector.is_a?(String)
      end

      # @sg-ignore
      # @param _task [Asana::Resources::Task]
      # @return [String]
      def evaluate(_task)
        task_selector
      end
    end

    # :estimate_exceeds_duration
    class EstimateExceedsDurationFunctionEvaluator < FunctionEvaluator
      FUNCTION_NAME = :estimate_exceeds_duration

      def matches?
        fn?(task_selector, FUNCTION_NAME)
      end

      # @param task [Asana::Resources::Task]
      # @return [Float]
      def calculate_allocated_hours(task)
        due_on = nil
        start_on = nil
        start_on = Date.parse(task.start_on) unless task.start_on.nil?
        due_on = Date.parse(task.due_on) unless task.due_on.nil?
        allocated_hours = 8.0
        # @sg-ignore
        allocated_hours = (due_on - start_on + 1).to_i * 8.0 if start_on && due_on
        allocated_hours
      end

      # @param task [Asana::Resources::Task]
      # @return [Boolean]
      def evaluate(task)
        custom_field = pull_custom_field_by_name_or_raise(task, 'Estimated time')

        # @sg-ignore
        # @type [Integer, nil]
        estimate_minutes = custom_field.fetch('number_value')

        # no estimate set
        return false if estimate_minutes.nil?

        estimate_hours = estimate_minutes / 60.0

        allocated_hours = calculate_allocated_hours(task)

        estimate_hours > allocated_hours
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
      Checkoff::TaskSelectorClasses::NotFunctionEvaluator,
      Checkoff::TaskSelectorClasses::NilPFunctionEvaluator,
      Checkoff::TaskSelectorClasses::EqualsPFunctionEvaluator,
      Checkoff::TaskSelectorClasses::TagPFunctionEvaluator,
      Checkoff::TaskSelectorClasses::CustomFieldValueFunctionEvaluator,
      Checkoff::TaskSelectorClasses::CustomFieldGidValueFunctionEvaluator,
      Checkoff::TaskSelectorClasses::CustomFieldGidValueContainsAnyGidFunctionEvaluator,
      Checkoff::TaskSelectorClasses::CustomFieldGidValueContainsAllGidsFunctionEvaluator,
      Checkoff::TaskSelectorClasses::AndFunctionEvaluator,
      Checkoff::TaskSelectorClasses::DuePFunctionEvaluator,
      Checkoff::TaskSelectorClasses::UnassignedPFunctionEvaluator,
      Checkoff::TaskSelectorClasses::DueDateSetPFunctionEvaluator,
      Checkoff::TaskSelectorClasses::FieldLessThanNDaysAgoFunctionEvaluator,
      Checkoff::TaskSelectorClasses::FieldGreaterThanOrEqualToNDaysFromTodayFunctionEvaluator,
      Checkoff::TaskSelectorClasses::CustomFieldLessThanNDaysFromNowFunctionEvaluator,
      Checkoff::TaskSelectorClasses::CustomFieldGreaterThanOrEqualToNDaysFromNowFunctionEvaluator,
      Checkoff::TaskSelectorClasses::LastStoryCreatedLessThanNDaysAgoFunctionEvaluator,
      Checkoff::TaskSelectorClasses::StringLiteralEvaluator,
      Checkoff::TaskSelectorClasses::EstimateExceedsDurationFunctionEvaluator,
    ].freeze

    # @param task_selector [Array]
    # @return [Boolean, Object, nil]
    def evaluate(task_selector)
      return true if task_selector.empty?

      # @param evaluator_class [Class<TaskSelectorClasses::FunctionEvaluator>]
      FUNCTION_EVALUTORS.each do |evaluator_class|
        # @sg-ignore
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
    # @param evaluator [TaskSelectorClasses::FunctionEvaluator]
    # @return [Boolean, Object, nil]
    def try_this_evaluator(task_selector, evaluator)
      # if task_selector is an array
      evaluated_args = if task_selector.is_a?(Array)
                         task_selector[1..].map.with_index do |item, index|
                           if evaluator.evaluate_arg?(index)
                             evaluate(item)
                           else
                             item
                           end
                         end
                       else
                         []
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
