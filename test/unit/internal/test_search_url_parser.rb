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
    task_selector = [:nil?, [:custom_field_gid_value, '1234']]
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
    task_selector = [:nil?, [:custom_field_gid_value, '456']]
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

    task_selector = [:and,
                     [:nil?, [:custom_field_gid_value, '456']],
                     ['not', ['custom_field_gid_value_contains_any_gid', '5678', ['12']]]]

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
    task_selector = [:nil?, [:custom_field_gid_value, '456']]
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
    task_selector = [:nil?, [:custom_field_gid_value, '5678']]
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_7
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_tags.ids=123&any_projects.ids=456_column_789~12'
    asana_api_params = {
      'tags.any' => '123',
      'projects.any' => '12',
      'sections.any' => '789',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_8
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?any_tags.ids=123&any_projects.ids=456_column_789'
    asana_api_params = {
      'tags.any' => '123',
      'sections.any' => '789',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_9
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?subtask=is_not_subtask&any_tags.ids=123&not_tags.ids=456~789~12~34&any_projects.ids=56_column_78'
    asana_api_params = {
      'is_subtask' => false,
      'tags.any' => '123',
      'tags.not' => '456,789,12,34',
      'sections.any' => '78',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_10
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?subtask=bogus&any_tags.ids=123&not_tags.ids=456~789~12~34&any_projects.ids=56_column_78'
    e = assert_raises(RuntimeError) do
      search_url_parser.convert_params(url)
    end
    assert_equal 'Teach me how to handle subtask = ["bogus"]', e.message
  end

  def test_convert_params_11
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?subtask=bogus&subtask=another_bogus&any_tags.ids=123&not_tags.ids=456~789~12~34&any_projects.ids=56_column_78'
    e = assert_raises(RuntimeError) do
      search_url_parser.convert_params(url)
    end
    assert_equal 'Teach me how to handle subtask = ["bogus", "another_bogus"]', e.message
  end

  def test_convert_params_12
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=bogus&any_projects.ids=123&custom_field_456.variant=no_value'
    e = assert_raises(RuntimeError) do
      search_url_parser.convert_params(url)
    end
    assert_equal 'Teach me how to handle completion = ["bogus"]', e.message
  end

  def test_convert_params_13
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&any_projects.ids=123&custom_field_456.variant=greater_than&custom_field_456.min=99999'
    asana_api_params = {
      'custom_fields.456.greater_than' => '99999',
      'completed' => false,
      'projects.any' => '123',
    }
    task_selector = []
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_14
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&any_projects.ids=123&custom_field_456.variant=greater_than&custom_field_456.min=99999&custom_field_456.blah=123'
    e = assert_raises(RuntimeError) do
      search_url_parser.convert_params(url)
    end
    assert_equal 'Teach me how to handle {"custom_field_456.min"=>["99999"], "custom_field_456.blah"=>["123"]}',
                 e.message
  end

  def test_convert_params_15
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&any_projects.ids=123&custom_field_456.variant=greater_than&custom_field_456.min=99999&custom_field_456.min=123'
    e = assert_raises(RuntimeError) do
      search_url_parser.convert_params(url)
    end
    assert_equal 'Teach me how to handle these remaining keys for custom_field_456.min: ' \
                 '{"custom_field_456.min"=>["99999", "123"]}',
                 e.message
  end

  def test_convert_params_16
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&subtask=is_not_subtask&any_projects.ids=123_column_456~123_column_789~12~34_column_56~123_column_78~123_column_1&custom_field_6.variant=doesnt_contain_any&custom_field_6.selected_options=7'
    asana_api_params = {
      'custom_fields.6.is_set' => 'true',
      'completed' => false,
      'is_subtask' => false,
      'projects.any' => '12',
      'sections.any' => '456,789,56,78,1',
    }
    task_selector = ['not', ['custom_field_gid_value_contains_any_gid', '6', ['7']]]
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_17
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&subtask=is_not_subtask&any_projects.ids=123&not_projects.ids=456&custom_field_789.variant=contains_any&custom_field_789.selected_options=12~34~56~78~90~1~2&custom_field_3.variant=is_not&custom_field_3.selected_options=4'
    asana_api_params = {
      'custom_fields.789.is_set' => 'true',
      'custom_fields.3.is_set' => 'true',
      'completed' => false,
      'is_subtask' => false,
      'projects.any' => '123',
      'projects.not' => '456',
    }
    task_selector = [:and,
                     ['custom_field_gid_value_contains_any_gid', '789', %w[12 34 56 78 90 1 2]],
                     ['not', ['custom_field_gid_value_contains_any_gid', '3', ['4']]]]
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def test_convert_params_18
    search_url_parser = get_test_object
    url = 'https://app.asana.com/0/search?completion=incomplete&subtask=is_not_subtask&any_projects.ids=123&not_projects.ids=456&custom_field_789.variant=contains_any&custom_field_789.selected_options=12~34~56~78~90~1~2'
    asana_api_params = {
      'custom_fields.789.is_set' => 'true', 'completed' => false, 'is_subtask' => false,
      'projects.any' => '123', 'projects.not' => '456'
    }
    task_selector = ['custom_field_gid_value_contains_any_gid', '789', %w[12 34 56 78 90 1 2]]
    assert_equal([asana_api_params, task_selector],
                 search_url_parser.convert_params(url))
  end

  def class_under_test
    Checkoff::Internal::SearchUrl::Parser
  end
end
