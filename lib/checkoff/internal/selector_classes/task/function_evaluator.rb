# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Task
      # Base class to evaluate a task selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<(Symbol, Array)>,String]
        # @param tasks [Checkoff::Tasks]
        # @param timelines [Checkoff::Timelines]
        # @param custom_fields [Checkoff::CustomFields]
        def initialize(selector:,
                       tasks:,
                       timelines:,
                       custom_fields:,
                       **_kwargs)
          @selector = selector
          @tasks = tasks
          @timelines = timelines
          @custom_fields = custom_fields
          super()
        end

        private

        # @return [Array<(Symbol, Array)>]
        attr_reader :selector
      end
    end
  end
end
