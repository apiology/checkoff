# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/search_url'

class TestSearchUrlParser < ClassTest
  def test_convert_params_1
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_projects.ids=123&custom_field_456.variant=is&custom_field_456.selected_options=789&custom_field_1234.variant=no_value'
    asana_api_params = {
      'projects.any' => '123',
      'custom_fields.456.value' => '789',
      'custom_fields.1234.is_set' => 'false',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_2
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_projects.ids=123&custom_field_456.variant=no_value&custom_field_789.variant=is&custom_field_789.selected_options=1234'
    asana_api_params = {
      'projects.any' => '123',
      'custom_fields.456.is_set' => 'false',
      'custom_fields.789.value' => '1234',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_3
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_projects.ids=123&custom_field_456.variant=no_value&custom_field_789.variant=is&custom_field_789.selected_options=1234&custom_field_5678.variant=is_not&custom_field_5678.selected_options=12&custom_field_34.variant=less_than&custom_field_34.max=100'
    asana_api_params = {
      'projects.any' => '123',
      'custom_fields.456.is_set' => 'false',
      'custom_fields.789.value' => '1234',
      'custom_fields.5678.is_set' => 'true',
      'custom_fields.34.less_than' => '100',
    }
    task_selector = ['not', ['custom_field_gid_value_contains_any_gid', '5678', ['12']]]
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_4
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?custom_field_123.variant=is_not&custom_field_123.selected_options=456~789'
    asana_api_params = {
      'custom_fields.123.is_set' => 'true',
    }
    task_selector = ['not', ['custom_field_gid_value_contains_any_gid', '123', %w[456 789]]]
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_5
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&any_projects.ids=123&custom_field_456.variant=no_value'
    asana_api_params = {
      'custom_fields.456.is_set' => 'false',
      'completed' => false,
      'projects.any' => '123',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_6
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&not_tags.ids=123~456~789&any_projects.ids=1234&custom_field_5678.variant=no_value&custom_field_12.variant=less_than&custom_field_12.max=2&custom_field_34.variant=less_than&custom_field_34.max=2&custom_field_56.variant=less_than&custom_field_56.max=202103'
    asana_api_params = {
      'custom_fields.5678.is_set' => 'false',
      'custom_fields.12.less_than' => '2',
      'custom_fields.34.less_than' => '2',
      'custom_fields.56.less_than' => '202103',
      'completed' => false,
      'tags.not' => '123,456,789',
      'projects.any' => '1234',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def class_under_test
    Checkoff::Internal::SearchUrl::Parser
  end
end
