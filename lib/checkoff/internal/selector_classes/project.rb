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
        # @param period [Symbol<:now_or_before,:this_week>]
        # @return [Boolean]
        def evaluate(project, period = :now_or_before)
          @projects.project_ready?(project, period: period)
        end
      end
    end
  end
end
