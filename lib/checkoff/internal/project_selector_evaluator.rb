# frozen_string_literal: true

require_relative 'selector_classes/common'
require_relative 'selector_classes/project'
require_relative 'selector_evaluator'

module Checkoff
  # Evaluates project selectors against a project
  class ProjectSelectorEvaluator < SelectorEvaluator
    # @param project [Asana::Resources::Project]
    # @param projects [Checkoff::Projects]
    # @param custom_fields [Checkoff::CustomFields]
    # @param workspaces [Checkoff::Workspaces]
    # @param portfolios [Checkoff::Portfolios]
    def initialize(project:,
                   projects: Checkoff::Projects.new,
                   custom_fields: Checkoff::CustomFields.new,
                   workspaces: Checkoff::Workspaces.new,
                   portfolios: Checkoff::Portfolios.new)
      @item = project
      @projects = projects
      @custom_fields = custom_fields
      @workspaces = workspaces
      @portfolios = portfolios
      super()
    end

    private

    COMMON_FUNCTION_EVALUATORS = (Checkoff::SelectorClasses::Common.constants.map do |const|
      Checkoff::SelectorClasses::Common.const_get(const)
    end - [Checkoff::SelectorClasses::Common::FunctionEvaluator]).freeze

    PROJECT_FUNCTION_EVALUATORS = (Checkoff::SelectorClasses::Project.constants.map do |const|
      Checkoff::SelectorClasses::Project.const_get(const)
    end - [Checkoff::SelectorClasses::Project::FunctionEvaluator]).freeze

    FUNCTION_EVALUTORS = (COMMON_FUNCTION_EVALUATORS + PROJECT_FUNCTION_EVALUATORS).freeze

    # @return [Array<Class<ProjectSelectorClasses::FunctionEvaluator>>]
    def function_evaluators
      FUNCTION_EVALUTORS
    end

    # @return [Hash]
    def initializer_kwargs
      {
        projects: projects, custom_fields: custom_fields,
        workspaces: workspaces, portfolios: portfolios
      }
    end

    # @return [Asana::Resources::Project]
    attr_reader :item
    # @return [Checkoff::Projects]
    attr_reader :projects
    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields
    # @return [Checkoff::Workspaces]
    attr_reader :workspaces
    # @return [Checkoff::Portfolios]
    attr_reader :portfolios
  end
end
