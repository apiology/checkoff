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
        # @sg-ignore dynamic-metaprogramming
        #   resource.due_date is dispatched via the asana gem's method_missing, so it's untyped
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
        # @sg-ignore needs-yard-annotation
        #   Checkoff::Projects#project_ready? has no @return tag
        # @return [Boolean]
        def evaluate(project, period = :now_or_before)
          # @sg-ignore needs-yard-annotation
          #   Checkoff::Projects#project_ready? has no @return tag
          @projects.project_ready?(project, period:)
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
        # @sg-ignore tool-limitation:class-ivar-dispatch
        #   cascades from Workspaces#default_workspace calling a class method through a
        #   Class<T>-typed ivar, a known Solargraph dispatch limitation
        #
        # @sg-ignore tool-limitation:class-ivar-dispatch
        #   same cascade from Workspaces#default_workspace
        # @return [Boolean]
        def evaluate(project, portfolio_name, workspace_name: nil, extra_project_fields: [])
          workspace_name ||= project.workspace&.name
          # @sg-ignore tool-limitation:class-ivar-dispatch
          #   Workspaces#default_workspace calls a class method through a Class<T>-typed ivar, a
          #   known Solargraph dispatch limitation
          workspace_name ||= @workspaces.default_workspace.name
          # @sg-ignore needs-yard-annotation
          #   Portfolios#projects_in_portfolio's Enumerable<Project> element type doesn't
          #   propagate to the @return below
          projects = @portfolios.projects_in_portfolio(workspace_name, portfolio_name,
                                                       extra_project_fields:)
          # @sg-ignore dynamic-metaprogramming
          #   p.name/project.name are dispatched via the asana gem's method_missing, so they're
          #   untyped
          projects.any? { |p| p.name == project.name }
        end
      end
    end
  end
end
