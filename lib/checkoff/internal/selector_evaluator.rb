# typed: false
# frozen_string_literal: true

module Checkoff
  # Base class to evaluate Asana resource selectors against an Asana resource
  class SelectorEvaluator
    # @param selector [Symbol, Array<Symbol, Integer, Array>]
    # @return [Boolean, Object, Array, nil]
    def evaluate(selector)
      return true if selector.empty?

      function_evaluators.each do |evaluator_class|
        # @type [Checkoff::SelectorClasses::FunctionEvaluator]
        # @sg-ignore dynamic-metaprogramming
        #   evaluator_class is iterated from function_evaluators and instantiated with a
        #   splatted **initializer_kwargs Hash from an overridable method — the constructor's
        #   keyword shape isn't visible statically
        evaluator = evaluator_class.new(selector:,
                                        **initializer_kwargs)

        next unless evaluator.matches?

        # @sg-ignore needs-yard-annotation
        #   try_this_evaluator's return type doesn't propagate to this method's @return
        return try_this_evaluator(selector, evaluator)
      end

      raise "Syntax issue trying to handle #{selector.inspect}"
    end

    private

    # @return [Hash]
    def initializer_kwargs
      {}
    end

    # @return [Array<Class<Checkoff::SelectorClasses::FunctionEvaluator>>]
    # @sg-ignore tool-limitation:raise-only-body
    #   abstract method body is only `raise`, so the bottom-type return can't match the declared
    #   @return
    def function_evaluators
      raise 'Implement me!'
    end

    # @param selector [Array]
    # @param evaluator [Checkoff::SelectorClasses::FunctionEvaluator]
    # @return [Array]
    def evaluate_args(selector, evaluator)
      return [] unless selector.is_a?(Array)

      # @sg-ignore tool-limitation:other
      #   Array#[range] slice return-type gap — selector[1..] is nilable per stdlib RBS even
      #   though selector.is_a?(Array) was already checked above
      selector[1..].map.with_index do |item, index|
        if evaluator.evaluate_arg?(index)
          evaluate(item)
        else
          item
        end
      end
    end

    # @param selector [Array]
    # @param evaluator [Checkoff::SelectorClasses::FunctionEvaluator]
    # @return [Boolean, Object, nil]
    def try_this_evaluator(selector, evaluator)
      # if selector is an array
      evaluated_args = evaluate_args(selector, evaluator)

      evaluator.evaluate(item, *evaluated_args)
    end

    # @return [Asana::Resources::Resource]
    attr_reader :item
  end
end
