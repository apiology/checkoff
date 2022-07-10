# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/search_url_parser'

class TestSearchUrlParser < ClassTest
  def test_convert_args_1
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_projects.ids=123&custom_field_456.variant=is&custom_field_456.selected_options=789&custom_field_1234.variant=no_value'
    asana_api_params = {
      'projects.any' => '123',
      'custom_fields.456.value' => '789',
      'custom_fields.1234.is_set' => 'false',
    }
    assert_equal(asana_api_params, search_url_parser.convert_args(url))
  end

  def test_convert_args_2
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_projects.ids=123&custom_field_456.variant=no_value&custom_field_789.variant=is&custom_field_789.selected_options=1234'
    asana_api_params = {
      'projects.any' => '123',
      'custom_fields.456.is_set' => 'false',
      'custom_fields.789.value' => '1234',
    }
    assert_equal(asana_api_params, search_url_parser.convert_args(url))
  end

  def test_convert_args_3
    search_url_parser = get_test_object
    # TODO: custom_field_5678.variant=is_not is not available in API
    # that I can see...
    url = 'https://app.asana.com/0/search?any_projects.ids=123&custom_field_456.variant=no_value&custom_field_789.variant=is&custom_field_789.selected_options=1234&custom_field_5678.variant=is_not&custom_field_5678.selected_options=12&custom_field_34.variant=less_than&custom_field_34.max=100'
    asana_api_params = {
      'projects.any' => '123',
      'custom_fields.456.is_set' => 'false',
      'custom_fields.789.value' => '1234',
    }
    assert_equal(asana_api_params, search_url_parser.convert_args(url))
  end

  def class_under_test
    Checkoff::Internal::SearchUrlParser
  end
end
