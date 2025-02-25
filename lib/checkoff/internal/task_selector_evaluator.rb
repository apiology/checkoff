# typed: true
# frozen_string_literal: true

require_relative 'selector_classes/common'
require_relative 'selector_classes/task'
require_relative 'selector_evaluator'

module Checkoff
  # Evaluates task selectors against a task
  class TaskSelectorEvaluator < SelectorEvaluator
    # @param task [Asana::Resources::Task]
    # @param tasks [Checkoff::Tasks]
    # @param timelines [Checkoff::Timelines]
    # @param custom_fields [Checkoff::CustomFields]
    def initialize(task:,
                   tasks: Checkoff::Tasks.new,
                   timelines: Checkoff::Timelines.new,
                   custom_fields: Checkoff::CustomFields.new)
      @item = task
      @tasks = tasks
      @timelines = timelines
      @custom_fields = custom_fields
      super()
    end

    private

    COMMON_FUNCTION_EVALUATORS = (Checkoff::SelectorClasses::Common.constants.map do |const|
      Checkoff::SelectorClasses::Common.const_get(const)
    end - [Checkoff::SelectorClasses::Common::FunctionEvaluator]).freeze
    private_constant :COMMON_FUNCTION_EVALUATORS

    TASK_FUNCTION_EVALUATORS = (Checkoff::SelectorClasses::Task.constants.map do |const|
      Checkoff::SelectorClasses::Task.const_get(const)
    end - [Checkoff::SelectorClasses::Task::FunctionEvaluator]).freeze
    private_constant :TASK_FUNCTION_EVALUATORS

    FUNCTION_EVALUTORS = (COMMON_FUNCTION_EVALUATORS + TASK_FUNCTION_EVALUATORS).freeze
    private_constant :FUNCTION_EVALUTORS

    # @return [Array<Class<Checkoff::SelectorClasses::Task::FunctionEvaluator>>]
    def function_evaluators
      FUNCTION_EVALUTORS
    end

    # @return [Hash]
    def initializer_kwargs
      { tasks:, timelines:, custom_fields: }
    end

    # @return [Asana::Resources::Task]
    attr_reader :item
    # @return [Checkoff::Tasks]
    attr_reader :tasks
    # @return [Checkoff::Timelines]
    attr_reader :timelines
    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields
  end
end
