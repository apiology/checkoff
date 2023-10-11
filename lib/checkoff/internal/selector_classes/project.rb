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
    end
  end
end
