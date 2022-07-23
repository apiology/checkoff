# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_selectors'

class TestTaskSelectors < ClassTest
  extend Forwardable

  let_mock :custom_field, :task, :custom_field_gid

  def test_filter_via_custom_field_gid_values_gids_no_enum_value
    custom_field_gid = '1202105567257391'
    enum_value_gid = '1202105685376214'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => nil,
    }
    task_selectors = get_test_object do
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end
    refute(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_any_gid',
                                                    custom_field_gid,
                                                    [enum_value_gid]]))
  end

  # not sure why this would be the case, so set an alarm so I can understand
  def test_filter_via_custom_field_custom_field_not_enabled
    custom_field_gid = '1202105567257391'
    enum_value_gid = '1202105685376214'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => {
        'gid' => enum_value_gid,
        'enabled' => false,
      },
    }
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([custom_field])
    end
    assert_raises(RuntimeError, /custom field with gid/) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
  end

  def test_filter_via_custom_field_none_matched
    custom_field_gid = '1202105567257391'
    enum_value_gid = '1202105685376214'
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([])
    end
    assert_raises(RuntimeError, /custom field with gid/) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
  end

  def test_filter_via_custom_field_gid_values_gids_custom_field_not_provided
    custom_field_gid = '1202105567257391'
    enum_value_gid = '1202105685376214'
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns(nil)
    end
    assert_raises(RuntimeError, /extra_fields/) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
  end

  def test_filter_via_custom_field_gid_values_gids
    custom_field_gid = '1202105567257391'
    enum_value_gid = '1202105685376214'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => {
        'gid' => enum_value_gid,
        'enabled' => true,
      },
    }
    task_selectors = get_test_object do
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end
    assert(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_any_gid',
                                                    custom_field_gid,
                                                    [enum_value_gid]]))
  end

  def test_filter_via_invalid_syntax
    task_selectors = get_test_object
    assert_raises(RuntimeError, /Syntax issue/) do
      task_selectors.filter_via_task_selector(task,
                                              [:bad_predicate?, [:custom_field_value,
                                                                 'custom_field_name']])
    end
  end

  def test_filter_via_custom_field_value_nil_false_found
    task_selectors = get_test_object do
      custom_fields = [custom_field]
      custom_field.expects(:fetch).with('name').returns('custom_field_name')
      custom_field.expects(:[]).with('display_value').returns('some value')
      task.expects(:custom_fields).returns(custom_fields)
    end
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_value,
                                                            'custom_field_name']]))
  end

  def test_filter_via_custom_field_value_custom_fields_not_provided
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns(nil)
    end
    assert_raises(RuntimeError, /extra_fields/) do
      task_selectors.filter_via_task_selector(task,
                                              [:nil?, [:custom_field_value,
                                                       'custom_field_name']])
    end
  end

  def test_filter_via_custom_field_value_nil_none_found
    task_selectors = get_test_object do
      custom_fields = []
      task.expects(:custom_fields).returns(custom_fields)
    end
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_value,
                                                            'custom_field_name']]))
  end

  def test_filter_via_task_selector_tag
    task_selectors = get_test_object do
      task.expects(:tags).returns([])
    end
    refute(task_selectors.filter_via_task_selector(task, [:tag, 'tag_name']))
  end

  def test_filter_via_task_selector_not
    task_selectors = get_test_object
    refute(task_selectors.filter_via_task_selector(task, [:not, []]))
  end

  def test_filter_via_task_selector_simple
    task_selectors = get_test_object
    assert(task_selectors.filter_via_task_selector(task, []))
  end

  def class_under_test
    Checkoff::TaskSelectors
  end
end
