# typed: true
# frozen_string_literal: true

require_relative 'project/function_evaluator'

module Checkoff
  module SelectorClasses
    # Project selector classes
    module Project
      # :due_date function
      class DueDateFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :due_date

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param resource [Asana::Resources::Project]
        # @return [String, nil]
        def evaluate(resource)
          resource.due_date
        end
      end

      # :ready? function
      class ReadyPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :ready?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param project [Asana::Resources::Project]
        # @param period [Symbol] - :now_or_before or :this_week
        # @return [Boolean]
        def evaluate(project, period = :now_or_before)
          @projects.project_ready?(project, period: period)
        end
      end

      # :in_portfolio_named? function
      class InPortfolioNamedPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :in_portfolio_named?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param project [Asana::Resources::Project]
        # @param portfolio_name [String]
        # @param workspace_name [String, nil]
        # @param extra_project_fields [Array<String>]
        #
        # @return [Boolean]
        def evaluate(project, portfolio_name, workspace_name: nil, extra_project_fields: [])
          workspace_name ||= project.workspace&.name
          workspace_name ||= @workspaces.default_workspace.name
          projects = @portfolios.projects_in_portfolio(workspace_name, portfolio_name,
                                                       extra_project_fields: extra_project_fields)
          projects.any? { |p| p.name == project.name }
        end
      end
    end
  end
end
