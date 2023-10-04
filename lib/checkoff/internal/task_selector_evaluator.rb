# frozen_string_literal: true

require_relative 'selector_classes/common'
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
      Checkoff::SelectorClasses::Common::NotFunctionEvaluator,
      Checkoff::SelectorClasses::Common::NilPFunctionEvaluator,
      Checkoff::SelectorClasses::Common::EqualsPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::TagPFunctionEvaluator,
      Checkoff::SelectorClasses::Common::CustomFieldValueFunctionEvaluator,
      Checkoff::SelectorClasses::Common::CustomFieldGidValueFunctionEvaluator,
      Checkoff::SelectorClasses::Common::CustomFieldGidValueContainsAnyGidFunctionEvaluator,
      Checkoff::SelectorClasses::Common::CustomFieldGidValueContainsAllGidsFunctionEvaluator,
      Checkoff::SelectorClasses::Common::AndFunctionEvaluator,
      Checkoff::SelectorClasses::Common::OrFunctionEvaluator,
      Checkoff::SelectorClasses::Task::DuePFunctionEvaluator,
      Checkoff::SelectorClasses::Task::DueBetweenRelativePFunctionEvaluator,
      Checkoff::SelectorClasses::Task::UnassignedPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::DueDateSetPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::FieldLessThanNDaysAgoPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::FieldGreaterThanOrEqualToNDaysFromTodayPFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldLessThanNDaysFromNowFunctionEvaluator,
      Checkoff::SelectorClasses::Task::CustomFieldGreaterThanOrEqualToNDaysFromNowFunctionEvaluator,
      Checkoff::SelectorClasses::Task::LastStoryCreatedLessThanNDaysAgoFunctionEvaluator,
      Checkoff::SelectorClasses::Common::StringLiteralEvaluator,
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
