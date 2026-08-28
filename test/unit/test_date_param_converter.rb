# typed: true
# frozen_string_literal: true

require_relative 'test_helper'
require 'checkoff/internal/search_url/date_param_converter'

class TestDateParamConverter < Minitest::Test
  # @return [void]
  def test_ensure_matched_raises_when_out_is_nil
    converter = Checkoff::Internal::SearchUrl::DateParamConverter.new(date_url_params: {})

    # ensure_matched! only receives nil when no known date prefix matched;
    # convert's own guards make that unreachable through the public API, so
    # this exercises the private guard directly.
    e = assert_raises(RuntimeError) { converter.send(:ensure_matched!, nil) }
    assert_match(/no date param matched a known prefix/, e.message)
  end

  # @return [void]
  def test_get_single_param_raises_on_nil_value
    # @sg-ignore deliberate:wrong-argument-type
    #   deliberately passing an Array<nil> where date_url_params declares
    #   Hash{String => Array<String>}, to exercise get_single_param's own
    #   runtime guard
    converter = Checkoff::Internal::SearchUrl::DateParamConverter.new(date_url_params: { 'key' => [nil] })

    # value[0] is declared nilable by RBS even though a real caller can't
    # construct this via the public API; this exercises the guard directly.
    e = assert_raises(RuntimeError) { converter.send(:get_single_param, 'key') }
    assert_match(/key to have a non-nil value/, e.message)
  end
end
