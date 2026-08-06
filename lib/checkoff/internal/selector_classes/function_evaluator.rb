# typed: true
# frozen_string_literal: true

require 'checkoff/internal/logging'

module Checkoff
  module SelectorClasses
    # Base class to evaluate types of selector functions
    class FunctionEvaluator
      include Logging

      # Concrete subclasses each declare their own initialize with their
      # specific keyword args (and set @selector themselves before calling
      # super()); this signature exists only so Solargraph can resolve
      # `evaluator_class.new(selector:, **kwargs)` call sites that hold a
      # `Class<FunctionEvaluator>` reference rather than a concrete subclass -
      # deliberately a no-op so a bare `super()` call from those subclasses
      # can't clobber the @selector they already set.
      # @param selector [Symbol, Array, String, nil]
      # @param _kwargs [Hash]
      def initialize(selector: nil, **_kwargs); end

      # @param _index [Integer]
      def evaluate_arg?(_index)
        true
      end

      # @return [Boolean]
      # @sg-ignore tool-limitation:raise-only-body
      #   return type could not be inferred — abstract method body is only `raise`
      def matches?
        raise 'Override me!'
      end

      # @param _task [Asana::Resources::Task]
      # @param _args [Array<Object>]
      # @return [Object]
      # @sg-ignore tool-limitation:raise-only-body
      #   return type could not be inferred — abstract method body is only `raise`
      def evaluate(_task, *_args)
        raise 'Implement me!'
      end

      private

      # @param object [Array<Symbol, Array>, Symbol]
      # @param fn_name [Symbol]
      # @return [Boolean]
      def fn?(object, fn_name)
        return false unless object.is_a?(Array) && !object.empty?

        [fn_name, fn_name.to_s].include?(object[0])
      end
    end
  end
end
