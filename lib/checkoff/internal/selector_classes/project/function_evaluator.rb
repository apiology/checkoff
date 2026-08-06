# typed: true
# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Project
      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<Symbol, Array>, Symbol]
        # @param projects [Checkoff::Projects]
        # @param portfolios [Checkoff::Portfolios]
        # @param workspaces [Checkoff::Workspaces]
        # @param _kwargs [Hash]
        def initialize(selector:,
                       projects:,
                       portfolios:,
                       workspaces:,
                       **_kwargs)
          @selector = selector
          @projects = projects
          @portfolios = portfolios
          @workspaces = workspaces
          super()
        end

        # @return [Checkoff::Projects]
        attr_reader :projects

        # @return [Checkoff::Portfolios]
        attr_reader :portfolios

        # @return [Checkoff::Workspaces]
        attr_reader :workspaces

        private

        # @return [Array<Symbol, Array>, Symbol]
        attr_reader :selector
      end
    end
  end
end
