# frozen_string_literal: true

require_relative 'selector_classes/task'
require_relative 'selector_evaluator'

module Checkoff
  # Evaluates task selectors against a task
  class TaskSelectorEvaluator < SelectorEvaluator
    # @param task [Asana::Resources::Task]
    # @param tasks [Checkoff::Tasks]
    def initialize(task:,
                   tasks: Checkoff::Tasks.new)
      @item = task
      @tasks = tasks
      super()
    end

    private

    FUNCTION_EVALUTORS = [
      Checkoff::SelectorClasses::Task::NotFunctionEvaluator,
      Checkoff::SelectorClasses::Task::NilPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::EqualsPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::TagPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldValueFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldGidValueFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldGidValueContainsAnyGidFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldGidValueContainsAllGidsFunctionEvaluator,
      Checkoff::SelectorClasses::Task::AndFunctionEvaluator,
      Checkoff::SelectorClasses::Task::OrFunctionEvaluator,
      Checkoff::SelectorClasses::Task::DuePFunctionEvaluator,
      Checkoff::SelectorClasses::Task::DueBetweenRelativePFunctionEvaluator,
      Checkoff::SelectorClasses::Task::UnassignedPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::DueDateSetPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::FieldLessThanNDaysAgoPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::FieldGreaterThanOrEqualToNDaysFromTodayPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldLessThanNDaysFromNowFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldGreaterThanOrEqualToNDaysFromNowFunctionEvaluator,
      Checkoff::SelectorClasses::Task::LastStoryCreatedLessThanNDaysAgoFunctionEvaluator,
      Checkoff::SelectorClasses::Task::StringLiteralEvaluator,
      Checkoff::SelectorClasses::Task::EstimateExceedsDurationFunctionEvaluator,
    ].freeze

    # @return [Array<Class<TaskSelectorClasses::FunctionEvaluator>>]
    def function_evaluators
      FUNCTION_EVALUTORS
    end

    # @return [Hash]
    def initializer_kwargs
      { tasks: tasks }
    end

    # @return [Asana::Resources::Task]
    attr_reader :item
    # @return [Checkoff::Tasks]
    attr_reader :tasks
  end
end
