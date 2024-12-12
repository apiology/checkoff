# typed: false
# frozen_string_literal: true

module Checkoff
  # Base class to evaluate Asana resource selectors against an Asana resource
  class SelectorEvaluator
    # @param selector [Array]
    # @return [Boolean, Object, nil]
    def evaluate(selector)
      return true if selector.empty?

      function_evaluators.each do |evaluator_class|
        # @type [Checkoff::SelectorClasses::FunctionEvaluator]
        # @sg-ignore
        evaluator = evaluator_class.new(selector: selector,
                                        **initializer_kwargs)

        next unless evaluator.matches?

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
    # @sg-ignore
    def function_evaluators
      raise 'Implement me!'
    end

    # @param selector [Array]
    # @param evaluator [Checkoff::SelectorClasses::FunctionEvaluator]
    # @return [Array]
    def evaluate_args(selector, evaluator)
      return [] unless selector.is_a?(Array)

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
