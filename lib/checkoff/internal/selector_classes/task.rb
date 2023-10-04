# frozen_string_literal: true

require_relative 'task/function_evaluator'

module Checkoff
  module SelectorClasses
    module Task
      # :and function
      class AndFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :and

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _task [Asana::Resources::Task]
        # @param lhs [Object]
        # @param rhs [Object]
        # @return [Object]
        def evaluate(_task, lhs, rhs)
          lhs && rhs
        end
      end

      # :or function
      #
      # Does not yet shortcut, but may in future - be careful with side
      # effects!
      class OrFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :or

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _task [Asana::Resources::Task]
        # @param lhs [Object]
        # @param rhs [Object]
        # @return [Object]
        def evaluate(_task, lhs, rhs)
          lhs || rhs
        end
      end

      # :not function
      class NotFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :not

        def matches?
          fn?(selector, FUNCTION_NAME)
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
          fn?(selector, :nil?)
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
          fn?(selector, FUNCTION_NAME)
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
          fn?(selector, :tag)
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
          fn?(selector, :due)
        end

        # @param task [Asana::Resources::Task]
        # @param ignore_dependencies [Boolean]
        # @return [Boolean]
        def evaluate(task, ignore_dependencies: false)
          @tasks.task_ready?(task, ignore_dependencies: ignore_dependencies)
        end
      end

      # :unassigned function
      class UnassignedPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :unassigned)
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
          fn?(selector, FUNCTION_NAME)
        end

        # @sg-ignore
        # @param task [Asana::Resources::Task]
        # @return [Boolean]
        def evaluate(task)
          !task.due_at.nil? || !task.due_on.nil?
        end
      end

      # :due_between_n_days function
      class DueBetweenRelativePFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :due_between_relative

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param beginning_num_days_from_now [Integer]
        # @param end_num_days_from_now [Integer]
        # @param ignore_dependencies [Boolean]
        #
        # @return [Boolean]
        def evaluate(task, beginning_num_days_from_now, end_num_days_from_now, ignore_dependencies: false)
          beginning_n_days_from_now_time = (Time.now + (beginning_num_days_from_now * 24 * 60 * 60))
          end_n_days_from_now_time = (Time.now + (end_num_days_from_now * 24 * 60 * 60))

          # @type [Date, Time, nil]
          task_date_or_time = pull_date_or_time_field_by_name(task, :start) ||
                              pull_date_or_time_field_by_name(task, :due)

          return false if task_date_or_time.nil?

          # if time
          in_range = if task_date_or_time.is_a?(Time)
                       task_date_or_time > beginning_n_days_from_now_time &&
                         task_date_or_time <= end_n_days_from_now_time
                     else
                       # if date
                       task_date_or_time > beginning_n_days_from_now_time.to_date &&
                         task_date_or_time <= end_n_days_from_now_time.to_date
                     end

          return false unless in_range

          return false if !ignore_dependencies && @tasks.incomplete_dependencies?(task)

          true
        end
      end

      # :custom_field_value function
      class CustomFieldValueFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_value

        def matches?
          fn?(selector, FUNCTION_NAME)
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
          fn?(selector, :custom_field_gid_value)
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
          fn?(selector, FUNCTION_NAME)
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
          fn?(selector, FUNCTION_NAME)
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
      class FieldLessThanNDaysAgoPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :field_less_than_n_days_ago

        def matches?
          fn?(selector, FUNCTION_NAME)
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
          date = pull_date_field_by_name(task, field_name)

          return false if date.nil?

          # @sg-ignore
          n_days_ago = Date.today - num_days
          # @sg-ignore
          date < n_days_ago
        end
      end

      # :field_greater_than_or_equal_to_n_days_from_today
      class FieldGreaterThanOrEqualToNDaysFromTodayPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :field_greater_than_or_equal_to_n_days_from_today

        def matches?
          fn?(selector, FUNCTION_NAME)
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
          date = pull_date_field_by_name(task, field_name)

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
          fn?(selector, FUNCTION_NAME)
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
          fn?(selector, FUNCTION_NAME)
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
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param num_days [Integer]
        # @param excluding_resource_subtypes [Array<String>]
        # @return [Boolean]
        def evaluate(task, num_days, excluding_resource_subtypes)
          # for whatever reason, .last on the enumerable does not impose ordering; .to_a does!

          # @type [Array<Asana::Resources::Story>]
          stories = task.stories(per_page: 100).to_a.reject do |story|
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
          selector.is_a?(String)
        end

        # @sg-ignore
        # @param _task [Asana::Resources::Task]
        # @return [String]
        def evaluate(_task)
          selector
        end
      end

      # :estimate_exceeds_duration
      class EstimateExceedsDurationFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :estimate_exceeds_duration

        def matches?
          fn?(selector, FUNCTION_NAME)
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
  end
end
