# typed: true
# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Common
      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<Symbol, Array>, Symbol]
        # @param custom_fields [Checkoff::CustomFields]
        # @param _kwargs [Hash]
        def initialize(selector:, custom_fields:, **_kwargs)
          @selector = selector
          @custom_fields = custom_fields
          super()
        end

        # @return [Checkoff::CustomFields]
        attr_reader :custom_fields

        private

        # @return [Array<Symbol, Array>, Symbol]
        attr_reader :selector
      end
    end
  end
end
