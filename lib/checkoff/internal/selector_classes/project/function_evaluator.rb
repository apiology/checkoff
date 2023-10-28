# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Project
      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<(Symbol, Array)>,String]
        # @param projects [Checkoff::Projects]
        def initialize(selector:,
                       projects:,
                       **_kwargs)
          @selector = selector
          @projects = projects
          super()
        end

        private

        # @return [Array<(Symbol, Array)>]
        attr_reader :selector
      end
    end
  end
end
