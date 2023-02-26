# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_selectors'

class TestTaskSelectors < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :tasks)

  let_mock :custom_field, :task, :custom_field_gid, :task_gid

  def test_filter_via_custom_field_gid_values_gids_no_enum_value
    custom_field_gid = '123'
    enum_value_gid = '456'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => nil,
      'resource_type' => 'custom_field',
      'resource_subtype' => 'enum',
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

  def test_filter_via_custom_field_gid_values_gids_no_enum_value_multi_enum
    custom_field_gid = '123'
    enum_value_gid = '456'
    custom_field = {
      'gid' => custom_field_gid,
      'multi_enum_values' => [],
      'resource_type' => 'custom_field',
      'resource_subtype' => 'multi_enum',
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

  def test_filter_via_custom_field_gid_values_gids_no_enum_value_new_type
    custom_field_gid = '123'
    enum_value_gid = '456'
    custom_field = {
      'gid' => custom_field_gid,
      'multi_enum_values' => [],
      'resource_type' => 'custom_field',
      'resource_subtype' => 'something_unknown',
    }
    task_selectors = get_test_object do
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
    assert_match(/Teach me how to handle resource_subtype something_unknown/, e.message)
  end

  # not sure why this would be the case, so set an alarm so I can understand
  def test_filter_via_custom_field_custom_field_not_enabled
    custom_field_gid = '123'
    enum_value_gid = '456'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => {
        'gid' => enum_value_gid,
        'enabled' => false,
      },
      'resource_type' => 'custom_field',
      'resource_subtype' => 'enum',
    }
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([custom_field])
    end
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
    assert_match(/Unexpected enabled value on custom field/, e.message)
  end

  def test_filter_via_custom_field_none_matched
    custom_field_gid = '123'
    enum_value_gid = '456'
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([])
      task.expects(:gid).returns(123)
    end
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
    assert_match(/custom field with gid/, e.message)
  end

  def test_filter_via_custom_field_gid_values_gids_custom_field_not_provided
    custom_field_gid = '123'
    enum_value_gid = '456'
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns(nil)
    end
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid',
                                               custom_field_gid,
                                               [enum_value_gid]])
    end
    assert_match(/extra_fields/, e.message)
  end

  def test_filter_via_custom_field_gid_values_gids
    custom_field_gid = '123'
    enum_value_gid = '456'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => {
        'gid' => enum_value_gid,
        'enabled' => true,
      },
      'resource_type' => 'custom_field',
      'resource_subtype' => 'enum',
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
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              [:bad_predicate?, [:custom_field_value,
                                                                 'custom_field_name']])
    end
    assert_match(/Syntax issue/, e.message)
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

  def mock_filter_via_custom_field_gid_value_gid_nil
    custom_fields = [custom_field]
    custom_field.expects(:fetch).with('gid').returns(custom_field_gid)
    task.expects(:custom_fields).returns(custom_fields)
    custom_field.expects(:[]).with('display_value').returns(nil)
  end

  def test_filter_via_custom_field_gid_value_gid_nil
    task_selectors = get_test_object do
      mock_filter_via_custom_field_gid_value_gid_nil
    end
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_gid_value,
                                                            custom_field_gid]]))
  end

  def test_filter_via_custom_field_value_custom_fields_not_provided
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns(nil)
    end
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              [:nil?, [:custom_field_value,
                                                       'custom_field_name']])
    end
    assert_match(/extra_fields/, e.message)
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

  def test_filter_via_custom_field_value_gid_nil_none_found
    task_selectors = get_test_object do
      custom_fields = []
      task.expects(:gid).returns('task_gid')
      task.expects(:custom_fields).returns(custom_fields)
    end
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              [:nil?, [:custom_field_gid_value,
                                                       custom_field_gid]])
    end
    assert_match(/Could not find custom field with gid/, e.message)
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

  def test_filter_via_task_selector_and
    task_selectors = get_test_object
    assert(task_selectors.filter_via_task_selector(task, [:and, [], []]))
  end

  def test_filter_via_task_selector_simple
    task_selectors = get_test_object
    assert(task_selectors.filter_via_task_selector(task, []))
  end

  def test_filter_via_task_selector_due
    task_selectors = get_test_object do
      tasks.expects(:task_ready?).with(task).returns(true)
    end
    assert(task_selectors.filter_via_task_selector(task, [:due]))
  end

  def test_filter_via_custom_field_gid_value_contains_all_gids
    custom_field_gid = '123'
    enum_value_gid = '456'
    custom_field = {
      'gid' => custom_field_gid,
      'enum_value' => {
        'gid' => enum_value_gid,
        'enabled' => true,
      },
      'resource_type' => 'custom_field',
      'resource_subtype' => 'enum',
    }
    task_selectors = get_test_object do
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end
    assert(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_all_gids',
                                                    custom_field_gid,
                                                    [enum_value_gid]]))
  end

  def class_under_test
    Checkoff::TaskSelectors
  end
end
