# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require 'checkoff/internal/search_url/custom_field_param_converter'

class TestCustomFieldParamConverter < Minitest::Test
  # @return [void]
  def test_convert_raises_on_key_with_no_gid
    converter = Checkoff::Internal::SearchUrl::CustomFieldParamConverter.new(
      custom_field_params: { 'custom_field' => ['1'] }
    )

    e = assert_raises(RuntimeError) { converter.convert }
    assert_match(/Unexpected custom field param key/, e.message)
  end

  # @return [void]
  def test_convert_raises_on_key_with_empty_gid
    # a double underscore leaves an empty (not trailing-dropped) segment at
    # index 2, so gid_and_suffix is '' rather than nil
    converter = Checkoff::Internal::SearchUrl::CustomFieldParamConverter.new(
      custom_field_params: { 'custom_field__x' => ['1'] }
    )

    e = assert_raises(RuntimeError) { converter.convert }
    assert_match(/Unexpected custom field param key/, e.message)
  end
end
