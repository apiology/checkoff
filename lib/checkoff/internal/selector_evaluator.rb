# typed: false
# frozen_string_literal: true

module Checkoff
  # Base class to evaluate Asana resource selectors against an Asana resource
  class SelectorEvaluator
    # @param selector [Symbol, Array<Symbol, String, Integer, Array>]
    # @return [Boolean, Object, Array, nil]
    def evaluate(selector)
      return true if selector.empty?

      function_evaluators.each do |evaluator_class|
        # @type [Checkoff::SelectorClasses::FunctionEvaluator]
        evaluator = evaluator_class.new(selector:,
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
    # @sg-ignore tool-limitation:no-bot-type
    #   abstract method always raises; declared type documents the override contract, not this
    #   body
    def function_evaluators
      raise 'Implement me!'
    end

    # @param selector [Symbol, Array]
    # @param evaluator [Checkoff::SelectorClasses::FunctionEvaluator]
    # @return [Array]
    def evaluate_args(selector, evaluator)
      return [] unless selector.is_a?(Array)

      # @sg-ignore needs-type-narrowing
      #   selector[1..] is genuinely nilable: Array#[] with an open-ended range returns nil
      #   when the start index exceeds the array length (confirmed: `[][1..]` => nil), and
      #   this method only guards selector.is_a?(Array), not non-empty. An empty-Array
      #   selector reaching here would NoMethodError on .map. Solargraph is correctly
      #   flagging a real gap, not a tool limitation; needs an explicit guard.
      selector[1..].map.with_index do |item, index|
        if evaluator.evaluate_arg?(index)
          evaluate(item)
        else
          item
        end
      end
    end

    # @param selector [Symbol, Array]
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
