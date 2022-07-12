# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_selectors'

class TestTaskSelectors < ClassTest
  extend Forwardable

  let_mock :custom_field, :task

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
