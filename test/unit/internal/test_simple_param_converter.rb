# typed: true
# frozen_string_literal: true

require_relative '../class_test'
require 'checkoff/internal/search_url/simple_param_converter'

# Test the Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam base class
class TestSimpleParamConverter < Minitest::Test
  # @return [void]
  def test_convert_raises_on_base_class
    simple_param = Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam.new(key: 'foo', values: ['bar'])

    e = assert_raises(RuntimeError) do
      simple_param.convert
    end

    assert_match(/Implement me!/, e.message)
  end
end
