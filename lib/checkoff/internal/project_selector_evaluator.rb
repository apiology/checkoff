# frozen_string_literal: true

require_relative 'selector_classes/common'
require_relative 'selector_classes/project'
require_relative 'selector_evaluator'

module Checkoff
  # Evaluates project selectors against a project
  class ProjectSelectorEvaluator < SelectorEvaluator
    # @param project [Asana::Resources::Project]
    # @param projects [Checkoff::Projects]
    def initialize(project:,
                   projects: Checkoff::Projects.new)
      @item = project
      @projects = projects
      super()
    end

    private

    FUNCTION_EVALUTORS = [
      Checkoff::SelectorClasses::Common::CustomFieldValueContainsAnyValueFunctionEvaluator,
    ].freeze

    # @return [Array<Class<ProjectSelectorClasses::FunctionEvaluator>>]
    def function_evaluators
      FUNCTION_EVALUTORS
    end

    # @return [Hash]
    def initializer_kwargs
      { projects: projects }
    end

    # @return [Asana::Resources::Project]
    attr_reader :item
    # @return [Checkoff::Projects]
    attr_reader :projects
  end
end
