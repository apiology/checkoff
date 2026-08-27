# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require 'checkoff/internal/selector_classes/common'

class TestSelectorClassesCommon < Minitest::Test
  # @return [void]
  def test_string_literal_evaluator_raises_on_non_string_selector
    # @sg-ignore deliberate:wrong-argument-type
    #   deliberately passing an Integer selector and a bare mock to exercise the
    #   runtime guard -- both violate the declared types on purpose
    evaluator = Checkoff::SelectorClasses::Common::StringLiteralEvaluator.new(selector: 123,
                                                                              custom_fields: mock('custom_fields'))
    task = mock('task')

    e = assert_raises(RuntimeError) do
      # @sg-ignore deliberate:wrong-argument-type
      #   deliberately passing a bare mock instead of a real resource
      evaluator.evaluate(task)
    end
    assert_match(/Expected a String selector/, e.message)
  end
end
