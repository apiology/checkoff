# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_selectors'

# rubocop:disable Metrics/ClassLength
class TestTaskSelectors < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::TaskSelectors]
  #  def get_test_object; end

  def_delegators(:@mocks, :tasks, :timelines)

  # @sg-ignore
  let_mock :custom_field
  # @!parse
  #  # @return [Mocha::Mock]
  #  def task; end
  # @sg-ignore
  let_mock :task
  # @sg-ignore
  let_mock :custom_field_gid
  # @sg-ignore
  let_mock :task_gid
  # @sg-ignore
  let_mock :story

  # @return [void]
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
      # @sg-ignore
      task.expects(:custom_fields).returns(custom_fields)
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_any_gid',
                                                    custom_field_gid,
                                                    [enum_value_gid]]))
  end

  # @return [void]
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

  # @return [void]
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
  #
  # @return [void]
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

  # @return [void]
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

  # @return [void]
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

  # @return [void]
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

  # @return [void]
  def test_filter_via_invalid_syntax
    task_selectors = get_test_object
    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              [:bad_predicate?, [:custom_field_value,
                                                                 'custom_field_name']])
    end

    assert_match(/Syntax issue/, e.message)
  end

  # @return [void]
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

  # @return [void]
  def mock_filter_via_custom_field_gid_value_gid_nil
    custom_fields = [custom_field]
    custom_field.expects(:fetch).with('gid').returns(custom_field_gid)
    task.expects(:custom_fields).returns(custom_fields)
    custom_field.expects(:[]).with('display_value').returns(nil)
  end

  # @return [void]
  def test_filter_via_custom_field_gid_value_gid_nil
    task_selectors = get_test_object do
      mock_filter_via_custom_field_gid_value_gid_nil
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_gid_value,
                                                            custom_field_gid]]))
  end

  # @return [void]
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

  # @return [void]
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

  # @return [void]
  def test_filter_via_task_selector_not
    task_selectors = get_test_object

    refute(task_selectors.filter_via_task_selector(task, [:not, []]))
  end

  def test_filter_via_task_selector_and
    task_selectors = get_test_object

    assert(task_selectors.filter_via_task_selector(task, [:and, [], []]))
  end

  def test_filter_via_task_selector_or
    task_selectors = get_test_object

    assert(task_selectors.filter_via_task_selector(task, [:or, [], []]))
  end

  def test_filter_via_task_selector_simple
    task_selectors = get_test_object

    assert(task_selectors.filter_via_task_selector(task, []))
  end

  def test_filter_via_task_selector_ready
    task_selectors = get_test_object do
      tasks.expects(:task_ready?).with(task, ignore_dependencies: false).returns(true)
    end

    assert(task_selectors.filter_via_task_selector(task, [:ready]))
  end

  def expect_now_jan_1_2019
    Time.expects(:now).returns(Time.new(2019, 1, 1, 0, 0, 0, 0)).at_least(1)
  end

  def expect_starts_jan_1_2019_midnight
    task.expects(:start_at).returns('2019-01-01T00:00:00Z').at_least(1)
  end

  def expect_no_incomplete_dependencies
    tasks.expects(:incomplete_dependencies?).with(task).returns(false)
  end

  def mock_filter_via_task_selector_ready_between_relative_starts_no
    expect_now_jan_1_2019
    expect_starts_jan_1_2019_midnight
    expect_no_incomplete_dependencies
  end

  def test_filter_via_task_selector_ready_between_relative_starts_now
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_starts_no
    end

    assert(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  def mock_filter_via_task_selector_ready_between_relative_starts_today
    expect_now_jan_1_2019
    task.expects(:start_at).returns(nil)
    task.expects(:start_on).returns('2019-01-01').at_least(1)
    expect_no_incomplete_dependencies
  end

  def test_filter_via_task_selector_ready_between_relative_starts_today
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_starts_today
    end

    assert(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  def mock_filter_via_task_selector_ready_between_relative_due_now
    expect_now_jan_1_2019
    task.expects(:start_at).returns(nil)
    task.expects(:start_on).returns(nil)
    task.expects(:due_at).returns('2019-01-01T00:00:00Z').at_least(1)
    expect_no_incomplete_dependencies
  end

  def test_filter_via_task_selector_ready_between_relative_due_now
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_due_now
    end

    assert(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  def mock_due_on_jan_1_2019
    task.expects(:due_at).returns(nil).at_least(0)
    task.expects(:due_on).returns('2019-01-01').at_least(1)
  end

  def expect_no_start
    task.expects(:start_at).returns(nil)
    task.expects(:start_on).returns(nil)
  end

  def mock_filter_via_task_selector_ready_between_relative_due_today
    expect_now_jan_1_2019
    expect_no_start
    mock_due_on_jan_1_2019
    expect_no_incomplete_dependencies
  end

  def test_filter_via_task_selector_ready_between_relative_due_today
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_due_today
    end

    assert(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  def expect_no_due
    task.expects(:due_at).returns(nil).at_least(0)
    task.expects(:due_on).returns(nil).at_least(1)
  end

  def mock_filter_via_task_selector_ready_between_relative_no_due
    expect_now_jan_1_2019
    expect_no_start
    expect_no_due
  end

  def test_filter_via_task_selector_ready_between_relative_no_due
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_no_due
    end

    refute(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  def expect_due_jan_1_2099
    task.expects(:due_at).returns(nil).at_least(1)
    task.expects(:due_on).returns('2099-01-01').at_least(1)
  end

  def mock_filter_via_task_selector_ready_between_relative_due_far_future
    expect_now_jan_1_2019
    expect_no_start
    expect_due_jan_1_2099
    expect_no_incomplete_dependencies.at_least(0)
  end

  def test_filter_via_task_selector_ready_between_relative_due_far_future
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_due_far_future
    end

    refute(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  def expect_incomplete_dependencies
    tasks.expects(:incomplete_dependencies?).with(task).returns(true)
  end

  def mock_filter_via_task_selector_ready_between_relative_due_today_but_dependent
    expect_now_jan_1_2019
    expect_no_start
    mock_due_on_jan_1_2019
    expect_incomplete_dependencies
  end

  def test_filter_via_task_selector_ready_between_relative_due_today_but_dependent
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_due_today_but_dependent
    end

    refute(task_selectors.filter_via_task_selector(task, [:ready_between_relative, -999, 2]))
  end

  # @return [void]
  def test_filter_via_task_selector_unassigned
    task_selectors = get_test_object do
      # @sg-ignore
      task.expects(:assignee).returns(nil)
    end

    # @sg-ignore
    assert(task_selectors.filter_via_task_selector(task, [:unassigned]))
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

  # @return [void]
  def test_filter_via_task_selector_due_date_set
    task_selectors = get_test_object do
      expect_no_due
    end

    refute(task_selectors.filter_via_task_selector(task, [:due_date_set]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_less_than_n_days_from_now
    task_selectors = get_test_object do
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    assert(task_selectors.filter_via_task_selector(task, [:custom_field_less_than_n_days_from_now, 'start date', 90]))
  end

  def test_filter_via_task_selector_custom_field_less_than_n_days_from_now_not_set
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => nil }]).at_least(1)
    end

    refute(task_selectors.filter_via_task_selector(task, [:custom_field_less_than_n_days_from_now, 'start date', 90]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_less_than_n_days_from_now_custom_field_not_found
    task_selectors = get_test_object do
      task.expects(:gid).returns('123')
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task, [:custom_field_less_than_n_days_from_now, 'start date', 90])
    end

    assert_match(/Could not find custom field with name start date in task 123 with custom fields/,
                 e.message)
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_greater_than_or_equal_to_n_days_from_now
    task_selectors = get_test_object do
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:custom_field_greater_than_or_equal_to_n_days_from_now,
                                                    'start date', 90]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_greater_than_or_equal_to_n_days_from_now_nil
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => nil }]).at_least(1)
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:custom_field_greater_than_or_equal_to_n_days_from_now,
                                                    'start date', 90]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_greater_than_or_equal_to_n_days_from_now_custom_field_not_found
    task_selectors = get_test_object do
      task.expects(:gid).returns('123')
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              [:custom_field_greater_than_or_equal_to_n_days_from_now, 'start date',
                                               90])
    end

    assert_match(/Could not find custom field with name start date in task 123 with custom fields/,
                 e.message)
  end

  # @return [void]
  def test_filter_via_task_selector_field_less_than_n_days_ago
    task_selectors = get_test_object do
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
      # @sg-ignore
      task.expects(:modified_at).returns(Time.new(1999, 12, 1, 0, 0, 0, '+00:00').to_s).at_least(1)
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:field_less_than_n_days_ago, :modified,
                                                    7]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_true
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => 960 }]).at_least(1)
      task.expects(:start_on).returns('2000-01-01').at_least(1)
      task.expects(:due_on).returns('2000-01-01').at_least(1)
    end

    # @sg-ignore
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_false_no_estimate_set
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => nil }]).at_least(1)
    end

    # @sg-ignore
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_true_only_due_set
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => 960 }]).at_least(1)
      task.expects(:start_on).returns(nil).at_least(1)
      task.expects(:due_on).returns('2000-01-01').at_least(1)
    end

    # @sg-ignore
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_true_no_dates_set
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => 960 }]).at_least(1)
      task.expects(:start_on).returns(nil).at_least(1)
      task.expects(:due_on).returns(nil).at_least(1)
    end

    # @sg-ignore
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_no_estimate_field
    task_selectors = get_test_object do
      task.expects(:custom_fields).returns([]).at_least(1)
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration]))
  end

  # @return [void]
  def test_filter_via_task_selector_field_less_than_n_days_ago_nil
    task_selectors = get_test_object do
      # @sg-ignore
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00').to_s).at_least(0)
      task.expects(:modified_at).returns(nil).at_least(1)
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:field_less_than_n_days_ago, :modified,
                                                    7]))
  end

  # @return [void]
  def test_filter_via_task_selector_field_less_than_n_days_ago_field_not_supported
    task_selectors = get_test_object

    e = assert_raises(RuntimeError) do
      task_selectors.filter_via_task_selector(task,
                                              [:field_less_than_n_days_ago, :bogus_at,
                                               7])
    end

    assert_match(/Teach me how to handle field bogus_at/, e.message)
  end

  # @return [void]
  def mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_on
    # @sg-ignore
    Date.expects(:today).returns(Date.new(2000, 1, 1)).at_least(1)
    # @sg-ignore
    task.expects(:due_at).returns(nil)
    # @sg-ignore
    task.expects(:due_on).returns(Date.new(2000, 1, 8).to_s).at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_on
    task_selectors = get_test_object do
      mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_on
    end

    # @sg-ignore
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:field_greater_than_or_equal_to_n_days_from_today, :due,
                                                    7]))
  end

  # @return [void]
  def test_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_at
    task_selectors = get_test_object do
      # @sg-ignore
      Date.expects(:today).returns(Date.new(2000, 1, 1)).at_least(0)
      # @sg-ignore
      task.expects(:due_at).returns(Time.new(1999, 12, 1, 0, 0, 0, '+00:00').to_s).at_least(1)
    end

    # @sg-ignore
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:field_greater_than_or_equal_to_n_days_from_today, :due,
                                                    7]))
  end

  # @return [void]
  def mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_nil
    # @sg-ignore
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00').to_s).at_least(0)
    # @sg-ignore
    task.expects(:due_at).returns(nil).at_least(1)
    # @sg-ignore
    task.expects(:due_on).returns(nil).at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_nil
    task_selectors = get_test_object do
      mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_nil
    end

    # @sg-ignore
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:field_greater_than_or_equal_to_n_days_from_today, :due,
                                                    7]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_equal_to_date
    task_selectors = get_test_object do
      # @sg-ignore
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:equals?, [:custom_field_value, 'end date'], '2000-01-15']))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_not_equal_to_date
    task_selectors = get_test_object do
      # @sg-ignore
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:equals?, [:custom_field_value, 'end date'], '2001-01-15']))
  end

  # @return [void]
  def test_filter_via_task_selector_last_story_created_less_than_n_days_ago_no_stories
    task_selectors = get_test_object do
      task.expects(:stories).returns([])
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:last_story_created_less_than_n_days_ago, 7, []]))
  end

  # @return [void]
  def mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_ancient
    task.expects(:stories).returns([story])
    story.expects(:resource_subtype).returns('blah')
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
    story.expects(:created_at).returns(Time.new(1950, 1, 1, 0, 0, 0, '+00:00').to_s)
  end

  # @return [void]
  def test_filter_via_task_selector_last_story_created_less_than_n_days_ago_ancient
    task_selectors = get_test_object do
      mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_ancient
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:last_story_created_less_than_n_days_ago, 7, []]))
  end

  # @return [void]
  def mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_recent
    task.expects(:stories).returns([story])
    story.expects(:resource_subtype).returns('blah')
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
    story.expects(:created_at).returns(Time.new(1999, 12, 31, 0, 0, 0, '+00:00').to_s)
  end

  # @return [void]
  def test_filter_via_task_selector_last_story_created_less_than_n_days_ago_recent
    task_selectors = get_test_object do
      mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_recent
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:last_story_created_less_than_n_days_ago, 7, []]))
  end

  # @return [void]
  def test_filter_via_task_selector_in_section_named_false
    task_selectors = get_test_object do
      task.expects(:memberships).returns([])
    end

    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_section_named?, 'foo']))
  end

  def test_filter_via_task_selector_in_section_named_true
    task_selectors = get_test_object do
      task.expects(:memberships).returns([{ 'section' => { 'name' => 'foo' } }])
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_section_named?, 'foo']))
  end

  def test_filter_via_task_selector_in_section_name_starts_with_true
    task_selectors = get_test_object do
      task.expects(:memberships).returns([{ 'section' => { 'name' => 'foo [100]' } }])
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:section_name_starts_with?, 'foo [']))
  end

  def test_dependent_on_previous_section_last_milestone
    task_selectors = get_test_object do
      timelines
        .expects(:task_dependent_on_previous_section_last_milestone?)
        .with(task,
              limit_to_portfolio_gid: nil).returns(true)
    end

    assert(task_selectors.filter_via_task_selector(task,
                                                   [:dependent_on_previous_section_last_milestone]))
  end

  # @return [Class<Checkoff::TaskSelectors>]
  def class_under_test
    Checkoff::TaskSelectors
  end
end
# rubocop:enable Metrics/ClassLength
