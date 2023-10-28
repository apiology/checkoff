# frozen_string_literal: true

require_relative 'task/function_evaluator'
require 'checkoff/internal/ready_between_relative'
require 'checkoff/internal/task_timing'

module Checkoff
  module SelectorClasses
    module Task
      # :section_name_starts_with? function
      class SectionNameStartsWithPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :section_name_starts_with?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @sg-ignore
        # @param task [Asana::Resources::Task]
        # @param section_name_prefix [String]
        # @return [Boolean]
        def evaluate(task, section_name_prefix)
          section_names = task.memberships.map do |membership|
            membership.fetch('section').fetch('name')
          end
          section_names.any? { |section_name| section_name.start_with? section_name_prefix }
        end
      end

      # :in_section_named? function
      class InSectionNamedPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :in_section_named?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @sg-ignore
        # @param task [Asana::Resources::Task]
        # @param section_name [String]
        # @return [Boolean]
        def evaluate(task, section_name)
          section_names = task.memberships.map do |membership|
            membership.fetch('section').fetch('name')
          end
          section_names.include? section_name
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

      # :ready function
      class ReadyFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :ready)
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

      # :ready_between_relative function
      class ReadyBetweenRelativePFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :ready_between_relative

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
          ready_between_relative = Checkoff::Internal::ReadyBetweenRelative.new(tasks: @tasks)
          ready_between_relative.ready_between_relative?(task,
                                                         beginning_num_days_from_now, end_num_days_from_now,
                                                         ignore_dependencies: ignore_dependencies)
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
          task_timing = Checkoff::Internal::TaskTiming.new

          date = task_timing.date_or_time_field_by_name(task, field_name)&.to_date

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
          task_timing = Checkoff::Internal::TaskTiming.new
          date = task_timing.date_or_time_field_by_name(task, field_name)&.to_date

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
          custom_field = pull_custom_field_by_name(task, 'Estimated time')

          return false if custom_field.nil?

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

      # :dependent_on_previous_section_last_milestone
      class DependentOnPreviousSectionLastMilestoneFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :dependent_on_previous_section_last_milestone

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param task [Asana::Resources::Task]
        # @param project_name [String]
        # @param limit_to_portfolio_gid [String, nil] If specified,
        # only projects in this portfolio will be evaluated.
        #
        # @return [Boolean]
        def evaluate(task, limit_to_portfolio_gid: nil)
          @timelines.task_dependent_on_previous_section_last_milestone?(task,
                                                                        limit_to_portfolio_gid: limit_to_portfolio_gid)
        end
      end

      # :in_portfolio_named? function
      class InPortfolioNamedFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :in_portfolio_named?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param task [Asana::Resources::Task]
        # @param portfolio_name [String]
        #
        # @return [Boolean]
        def evaluate(task, portfolio_name)
          @tasks.in_portfolio_named?(task, portfolio_name)
        end
      end
    end
  end
end
