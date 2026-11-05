# typed: true
# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Task
      # Base class to evaluate a task selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<Symbol, Array>, Symbol, String]
        # @param tasks [Checkoff::Tasks]
        # @param timelines [Checkoff::Timelines]
        # @param custom_fields [Checkoff::CustomFields]
        # @param time_class [Class<Time>]
        # @param _kwargs [Hash]
        def initialize(selector:,
                       tasks:,
                       timelines:,
                       custom_fields:,
                       time_class: Time,
                       **_kwargs)
          @selector = selector
          @tasks = tasks
          @timelines = timelines
          @custom_fields = custom_fields
          @time_class = time_class
          super()
        end

        # @return [Checkoff::Tasks]
        attr_reader :tasks

        # @return [Checkoff::Timelines]
        attr_reader :timelines

        # @return [Checkoff::CustomFields]
        attr_reader :custom_fields

        # @return [Class<Time>]
        attr_reader :time_class

        private

        # @return [Array<Symbol, Array>, Symbol, String]
        attr_reader :selector
      end
    end
  end
end
