# typed: true
# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Section
      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array(Symbol, Array), String]
        # @param client [Asana::Client]
        # @param sections [Checkoff::Sections]
        # @param kwargs [Hash]
        def initialize(selector:,
                       sections:,
                       client:,
                       **kwargs)
          @selector = selector
          @sections = sections
          @client = client
          super()
        end

        # @return [Checkoff::Sections]
        attr_reader :sections

        # @return [Asana::Client]
        attr_reader :client

        private

        # @return [Array(Symbol, Array)]
        attr_reader :selector
      end
    end
  end
end
