# typed: false
# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Section
      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<(Symbol, Array)>,String]
        # @param client [Asana::Client]
        # @param sections [Checkoff::Sections]
        def initialize(selector:,
                       sections:,
                       client:,
                       **)
          @selector = selector
          @sections = sections
          @client = client
          super()
        end

        private

        # @return [Array<(Symbol, Array)>]
        attr_reader :selector

        # @return [Asana::Client]
        attr_reader :client
      end
    end
  end
end
