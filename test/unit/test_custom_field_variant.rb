# typed: true
# frozen_string_literal: true

require_relative 'test_helper'
require 'checkoff/internal/search_url/custom_field_variant'

class TestCustomFieldVariant < Minitest::Test
  # @return [void]
  def test_base_class_convert_raises_not_implemented
    base = Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant.new('123', {})

    assert_raises(NotImplementedError) { base.convert }
  end
end
