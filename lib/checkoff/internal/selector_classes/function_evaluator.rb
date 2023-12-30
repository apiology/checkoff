# frozen_string_literal: true

require 'checkoff/internal/logging'

module Checkoff
  module SelectorClasses
    # Base class to evaluate types of selector functions
    class FunctionEvaluator
      include Logging

      # @sg-ignore
      # @param _index [Integer]
      def evaluate_arg?(_index)
        true
      end

      # @sg-ignore
      # @return [Boolean]
      def matches?
        raise 'Override me!'
      end

      # @param _task [Asana::Resources::Task]
      # @param _args [Array<Object>]
      # @return [Object]
      # @sg-ignore
      def evaluate(_task, *_args)
        raise 'Implement me!'
      end

      private

      # @param object [Object]
      # @param fn_name [Symbol]
      def fn?(object, fn_name)
        object.is_a?(Array) && !object.empty? && [fn_name, fn_name.to_s].include?(object[0])
      end
    end
  end
end
