# typed: true
# frozen_string_literal: true

require_relative 'task/function_evaluator'
require 'checkoff/internal/task_timing'

module Checkoff
  module SelectorClasses
    module Task
      # :in_a_real_project? function
      class InARealProjectPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :in_a_real_project?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @return [Boolean]
        def evaluate(task)
          # @type [Hash{'unwrapped' => Hash}]
          task_data = tasks.task_to_h(task)
          # @type [Hash{'membership_by_project_name' => Hash}]
          # @sg-ignore upstream-type-annotation:rbs-4-1-regression
          #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
          #   https://github.com/castwide/solargraph/pull/1228
          unwrapped = task_data.fetch('unwrapped')
          # @type [Array]
          # @sg-ignore upstream-type-annotation:rbs-4-1-regression
          #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
          #   https://github.com/castwide/solargraph/pull/1228
          projects = unwrapped.fetch('membership_by_project_name').keys
          !(projects - [:my_tasks]).empty?
        end
      end

      # :section_name_starts_with? function
      class SectionNameStartsWithPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :section_name_starts_with?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param section_name_prefix [String]
        # @return [Boolean]
        def evaluate(task, section_name_prefix)
          # @type [Hash{'unwrapped' => Hash}]
          task_data = tasks.task_to_h(task)
          # @type [Hash{'membership_by_section_name' => Hash}]
          # @sg-ignore upstream-type-annotation:rbs-4-1-regression
          #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
          #   https://github.com/castwide/solargraph/pull/1228
          unwrapped = task_data.fetch('unwrapped')
          # @type [Array]
          # @sg-ignore upstream-type-annotation:rbs-4-1-regression
          #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
          #   https://github.com/castwide/solargraph/pull/1228
          section_names = unwrapped.fetch('membership_by_section_name').keys
          section_names.any? do |section_name|
            String(section_name).start_with?(section_name_prefix)
          end
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

        # @param task [Asana::Resources::Task]
        # @param section_name [String]
        # @return [Boolean]
        def evaluate(task, section_name)
          # @type [Hash{'unwrapped' => Hash}]
          task_data = tasks.task_to_h(task)
          # @type [Hash{'membership_by_section_name' => Hash}]
          # @sg-ignore upstream-type-annotation:rbs-4-1-regression
          #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
          #   https://github.com/castwide/solargraph/pull/1228
          unwrapped = task_data.fetch('unwrapped')
          # @type [Array]
          # @sg-ignore upstream-type-annotation:rbs-4-1-regression
          #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
          #   https://github.com/castwide/solargraph/pull/1228
          section_names = unwrapped.fetch('membership_by_section_name').keys
          section_names.any?(section_name)
        end
      end

      # :in_project_named? function
      class InProjectNamedPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :in_project_named?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param project_name [String]
        # @return [Boolean]
        # @sg-ignore upstream-type-annotation:rbs-4-1-regression
        #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
        #   https://github.com/castwide/solargraph/pull/1228
        def evaluate(task, project_name)
          project_names = task.memberships.map do |membership|
            # @sg-ignore upstream-type-annotation:rbs-4-1-regression
            #   Hash#fetch generic<X> leak on rbs >= 4.1.0, fix in progress upstream
            #   https://github.com/castwide/solargraph/pull/1228
            membership.fetch('project').fetch('name')
          end
          project_names.include?(project_name)
        end
      end

      # :in_portfolio_more_than_once? function
      class InPortfolioMoreThanOncePFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :in_portfolio_more_than_once?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param portfolio_name [String]
        # @return [Boolean]
        def evaluate(task, portfolio_name)
          tasks.in_portfolio_more_than_once?(task, portfolio_name)
        end
      end

      # :tag? function
      class TagPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :tag?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param tag_name [String]
        # @return [Boolean]
        def evaluate(task, tag_name)
          # @type [Array<Asana::Resources::Tag>]
          tags = task.tags.to_a
          tag_names = tags.map(&:name)
          tag_names.include?(tag_name)
        end
      end

      # :ready? function
      #
      # See GLOSSARY.md and tasks.rb#task_ready? for more information.
      class ReadyPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :ready?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param period [Symbol] - :now_or_before or :this_week
        # @param ignore_dependencies [Boolean]
        # @return [Boolean]
        # rubocop:disable Style/OptionalBooleanParameter
        def evaluate(task, period = :now_or_before, ignore_dependencies = false)
          tasks.task_ready?(task, period:, ignore_dependencies:)
        end
        # rubocop:enable Style/OptionalBooleanParameter
      end

      # :in_period? function
      class InPeriodPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :in_period?)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param field_name [Symbol] See Checksoff::Tasks#in_period?
        # @param period [Symbol,Array<Symbol>] See Checkoff::Timing#in_period?
        # @return [Boolean]
        def evaluate(task, field_name, period)
          tasks.in_period?(task, field_name, period)
        end
      end

      # :unassigned? function
      class UnassignedPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :unassigned?)
        end

        # @param task [Asana::Resources::Task]
        # @return [Boolean]
        def evaluate(task)
          task.assignee.nil? == true
        end
      end

      # :due_date_set? function
      class DueDateSetPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :due_date_set?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param task [Asana::Resources::Task]
        # @return [Boolean]
        # @sg-ignore tool-limitation:context-dependent-return-inference
        #   Checkoff::SelectorClasses::Task::DueDateSetPFunctionEvaluator#evaluate return type
        #   could not be inferred — confirmed via a minimal Sorbet-free repro that the bare
        #   negated-&&-of-.nil?-checks expression alone is not the trigger (it types fine in
        #   isolation, with or without a T.cast wrapper); only reproduces inside this real
        #   multi-class file, not in an isolated 1-2 class repro — same class of context-
        #   dependent corruption already reported upstream in castwide/solargraph#1233
        def evaluate(task)
          T.cast(!(task.due_at.nil? && task.due_on.nil?), T::Boolean)
        end
      end

      # :last_story_created_less_than_n_days_ago? function
      class LastStoryCreatedLessThanNDaysAgoPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :last_story_created_less_than_n_days_ago?

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
            # @sg-ignore upstream-type-annotation:rbs-4-1-regression
            #   story's inferred block param type regressed on rbs >= 4.1.0, fix in progress
            #   upstream
            #   https://github.com/castwide/solargraph/pull/1228
            excluding_resource_subtypes.include? story.resource_subtype
          end
          return true if stories.empty? # no stories == infinitely old!

          last_story = T.must(stories.last)
          last_story_created_at = Time.parse(last_story.created_at)
          n_days_ago = Time.at(Time.now.to_i - (num_days * 86_400))
          last_story_created_at < n_days_ago
        end
      end

      # :estimate_exceeds_duration?
      class EstimateExceedsDurationPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :estimate_exceeds_duration?

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
          allocated_hours = (due_on - start_on + 1).to_i * 8.0 if start_on && due_on
          allocated_hours
        end

        # @param task [Asana::Resources::Task]
        # @return [Boolean]
        def evaluate(task)
          custom_field = custom_fields.resource_custom_field_by_name(task, 'Estimated time')

          return false if custom_field.nil?

          # @type [Integer, nil]
          estimate_minutes = custom_field.fetch('number_value')

          # no estimate set
          return false if estimate_minutes.nil?

          estimate_hours = estimate_minutes / 60.0

          allocated_hours = calculate_allocated_hours(task)

          estimate_hours > allocated_hours
        end
      end

      # :dependent_on_previous_section_last_milestone?
      class DependentOnPreviousSectionLastMilestonePFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :dependent_on_previous_section_last_milestone?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param task [Asana::Resources::Task]
        # @param limit_to_portfolio_gid [String, nil] If specified,
        #   only projects in this portfolio will be evaluated.
        #
        # @return [Boolean]
        def evaluate(task, limit_to_portfolio_gid: nil)
          timelines.task_dependent_on_previous_section_last_milestone?(task,
                                                                       limit_to_portfolio_gid:)
        end
      end

      # :in_portfolio_named? function
      class InPortfolioNamedPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :in_portfolio_named?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param task [Asana::Resources::Task]
        # @param portfolio_name [String]
        #
        # @return [Boolean]
        def evaluate(task, portfolio_name)
          tasks.in_portfolio_named?(task, portfolio_name)
        end
      end

      # :last_task_milestone_does_not_depend_on_this_task? function
      class LastTaskMilestoneDoesNotDependOnThisTaskPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :last_task_milestone_does_not_depend_on_this_task?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param limit_to_portfolio_name [String, nil]
        #
        # @return [Boolean]
        def evaluate(task, limit_to_portfolio_name = nil)
          !timelines.last_task_milestone_depends_on_this_task?(task,
                                                               limit_to_portfolio_name:)
        end
      end

      # :milestone? function
      class MilestonePFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :milestone?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        #
        # @return [Boolean]
        def evaluate(task)
          resource_subtype = task.resource_subtype
          raise 'Please add resource_subtype to extra_fields' if resource_subtype.nil?

          resource_subtype == 'milestone'
        end
      end

      # :milestone_does_not_depend_on_this_task? function
      class NoMilestoneDependsOnThisTaskPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :no_milestone_depends_on_this_task?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param task [Asana::Resources::Task]
        # @param limit_to_portfolio_name [String, nil]
        #
        # @return [Boolean]
        def evaluate(task, limit_to_portfolio_name = nil)
          !timelines.any_milestone_depends_on_this_task?(task,
                                                         limit_to_portfolio_name:)
        end
      end
    end
  end
end
