# typed: false
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

  def_delegators(:@mocks, :tasks, :timelines, :client)

  let_mock :custom_field
  # @!parse
  #  # @return [Mocha::Mock]
  #  def task; end
  let_mock :task
  let_mock :custom_field_gid
  let_mock :task_gid
  let_mock :story
  let_mock :custom_field_value_gid_1

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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_any_gid?',
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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_any_gid?',
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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields).at_least(1)
      task.expects(:gid).returns(123)
    end
    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid?',
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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([custom_field])
    end
    # should not raise
    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    result = task_selectors.filter_via_task_selector(task,
                                                     ['custom_field_gid_value_contains_any_gid?',
                                                      custom_field_gid,
                                                      [enum_value_gid]])

    assert(result)
  end

  # @return [void]
  def test_filter_via_custom_field_none_matched
    custom_field_gid = '123'
    enum_value_gid = '456'
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([]).at_least(1)
      task.expects(:gid).returns(123).at_least(1)
    end
    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid?',
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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns(nil).at_least(1)
      task.expects(:gid).returns(123)
    end
    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              ['custom_field_gid_value_contains_any_gid?',
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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_any_gid?',
                                                    custom_field_gid,
                                                    [enum_value_gid]]))
  end

  # @return [void]
  def test_filter_via_invalid_syntax
    task_selectors = get_test_object
    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:bad_predicate?, [:custom_field_value,
                                                                 'custom_field_name']])
    end

    assert_match(/Syntax issue/, e.message)
  end

  # @return [void]
  def test_filter_via_custom_field_value_nil_false_found
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      # @sg-ignore Unresolved call to custom_field
      custom_fields = [custom_field]
      # @sg-ignore Unresolved call to custom_field
      custom_field.expects(:fetch).with('name').returns('custom_field_name')
      # @sg-ignore Unresolved call to custom_field
      custom_field.expects(:[]).with('display_value').returns('some value')
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_value,
                                                            'custom_field_name']]))
  end

  # @return [void]
  def mock_filter_via_custom_field_gid_value_gid_nil
    # @sg-ignore Unresolved call to custom_field
    custom_fields = [custom_field]
    # @sg-ignore Unresolved call to custom_field
    custom_field.expects(:fetch).with('gid').returns(custom_field_gid)
    task.expects(:custom_fields).returns(custom_fields)
    # @sg-ignore Unresolved call to custom_field
    custom_field.expects(:[]).with('display_value').returns(nil)
  end

  # @return [void]
  def test_filter_via_custom_field_gid_value_gid_nil
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      mock_filter_via_custom_field_gid_value_gid_nil
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_gid_value,
                                                            # @sg-ignore Unresolved call to custom_field_gid
                                                            custom_field_gid]]))
  end

  # @return [void]
  def test_filter_via_custom_field_value_custom_fields_not_provided
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns(nil)
    end
    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:nil?, [:custom_field_value,
                                                       'custom_field_name']])
    end

    assert_match(/extra_fields/, e.message)
  end

  # @return [void]
  def test_filter_via_custom_field_value_nil_none_found
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = []
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:nil?, [:custom_field_value,
                                                            'custom_field_name']]))
  end

  # @return [void]
  def test_filter_via_custom_field_value_gid_nil_none_found
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = []
      task.expects(:gid).returns('task_gid')
      task.expects(:custom_fields).returns(custom_fields)
    end
    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:nil?, [:custom_field_gid_value,
                                                       # @sg-ignore Unresolved call to custom_field_gid
                                                       custom_field_gid]])
    end

    assert_match(/Could not find custom field with gid/, e.message)
  end

  # @return [void]
  def test_filter_via_task_selector_tag
    task_selectors = get_test_object do
      task.expects(:tags).returns([])
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:tag?, 'tag_name']))
  end

  # @return [void]
  def test_filter_via_task_selector_not
    task_selectors = get_test_object

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:not, []]))
  end

  # @return [void]
  def test_filter_via_task_selector_and
    task_selectors = get_test_object

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:and, [], []]))
  end

  # @return [void]
  def test_filter_via_task_selector_or
    task_selectors = get_test_object

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:or, [], []]))
  end

  # @return [void]
  def test_filter_via_task_selector_simple
    task_selectors = get_test_object

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, []))
  end

  # @return [void]
  def test_filter_via_task_selector_ready
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_ready?).with(task, period: :now_or_before, ignore_dependencies: false).returns(true)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:ready?]))
  end

  # @return [void]
  def expect_now_jan_1_2019
    Time.expects(:now).returns(Time.new(2019, 1, 1, 0, 0, 0, 0)).at_least(0)
  end

  # @return [void]
  def expect_starts_jan_1_2019_midnight
    task.expects(:start_at).returns('2019-01-01T00:00:00Z').at_least(1)
  end

  # @return [void]
  def expect_no_incomplete_dependencies
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:incomplete_dependencies?).with(task).returns(false)
  end

  # @return [void]
  def mock_filter_via_task_selector_ready_between_relative_starts_no
    expect_tasks_not_mocked
    expect_now_jan_1_2019
    expect_starts_jan_1_2019_midnight
  end

  # @return [void]
  def test_filter_via_task_selector_ready_between_relative_starts_now
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_starts_no
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_period?, :ready, [:between_relative_days, nil, 2]]))
  end

  # @return [void]
  def mock_filter_via_task_selector_ready_between_relative_starts_today
    expect_now_jan_1_2019
    task.expects(:start_at).returns(nil)
    task.expects(:start_on).returns('2019-01-01').at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_ready_between_relative_starts_today
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:tasks] = Checkoff::Tasks.new(client:)
      mock_filter_via_task_selector_ready_between_relative_starts_today
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_period?, :ready, [:between_relative_days, nil, 2]]))
  end

  # @return [void]
  def mock_filter_via_task_selector_ready_between_relative_due_now
    expect_now_jan_1_2019
    task.expects(:start_at).returns(nil)
    task.expects(:start_on).returns(nil)
    task.expects(:due_at).returns('2019-01-01T00:00:00Z').at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_ready_between_relative_due_now
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:tasks] = Checkoff::Tasks.new(client:)
      mock_filter_via_task_selector_ready_between_relative_due_now
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_period?, :ready, [:between_relative_days, nil, 2]]))
  end

  # @return [void]
  def mock_due_on_jan_1_2019
    task.expects(:due_at).returns(nil).at_least(0)
    task.expects(:due_on).returns('2019-01-01').at_least(1)
  end

  # @return [void]
  def expect_no_start
    task.expects(:start_at).returns(nil)
    task.expects(:start_on).returns(nil)
  end

  # @return [void]
  def mock_filter_via_task_selector_ready_between_relative_due_today
    expect_tasks_not_mocked
    expect_now_jan_1_2019
    expect_no_start
    mock_due_on_jan_1_2019
  end

  # @return [void]
  def test_filter_via_task_selector_ready_between_relative_due_today
    task_selectors = get_test_object do
      mock_filter_via_task_selector_ready_between_relative_due_today
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_period?, :ready, [:between_relative_days, nil, 2]]))
  end

  # @return [void]
  def expect_no_due
    task.expects(:due_at).returns(nil).at_least(0)
    task.expects(:due_on).returns(nil).at_least(1)
  end

  # @return [void]
  def mock_filter_via_task_selector_ready_between_relative_no_due
    expect_now_jan_1_2019
    expect_no_start
    expect_no_due
  end

  # @return [void]
  def test_filter_via_task_selector_ready_between_relative_no_due
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:tasks] = Checkoff::Tasks.new(client:)
      mock_filter_via_task_selector_ready_between_relative_no_due
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:in_period?, :ready, [:between_relative_days, nil, 2]]))
  end

  # @return [void]
  def expect_due_jan_1_2099
    task.expects(:due_at).returns(nil).at_least(1)
    task.expects(:due_on).returns('2099-01-01').at_least(1)
  end

  # @return [void]
  def mock_filter_via_task_selector_ready_between_relative_due_far_future
    expect_now_jan_1_2019
    expect_no_start
    expect_due_jan_1_2099
    # @sg-ignore Unresolved call to at_least on void
    expect_no_incomplete_dependencies.at_least(0)
  end

  # @return [void]
  def test_filter_via_task_selector_ready_between_relative_due_far_future
    task_selectors = get_test_object do
      expect_tasks_not_mocked
      mock_filter_via_task_selector_ready_between_relative_due_far_future
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:in_period?, :ready, [:between_relative_days, nil, 2]]))
  end

  # @return [void]
  def expect_incomplete_dependencies
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:incomplete_dependencies?).with(task).returns(true)
  end

  # @return [void]
  def expect_tasks_not_mocked
    # @sg-ignore Unresolved call to @mocks
    @mocks[:tasks] = Checkoff::Tasks.new(client:)
  end

  # @return [void]
  def test_filter_via_task_selector_unassigned
    task_selectors = get_test_object do
      task.expects(:assignee).returns(nil)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:unassigned?]))
  end

  # @return [void]
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
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   ['custom_field_gid_value_contains_all_gids?',
                                                    custom_field_gid,
                                                    [enum_value_gid]]))
  end

  # @return [void]
  def test_filter_via_task_selector_due_date_set
    task_selectors = get_test_object do
      expect_no_due
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:due_date_set?]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_less_than_n_days_from_now
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      expect_tasks_not_mocked
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, [:custom_field, 'start date'],
                                                    [:less_than_n_days_from_now, 90]]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_less_than_n_days_from_now_not_set
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      expect_tasks_not_mocked
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => nil }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, [:custom_field, 'start date'],
                                                    [:less_than_n_days_from_now, 90]]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_less_than_n_days_from_now_custom_field_not_found
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      expect_tasks_not_mocked
      task.expects(:gid).returns('123')
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:in_period?, [:custom_field, 'start date'],
                                               [:less_than_n_days_from_now, 90]])
    end

    assert_match(/Could not find custom field with name start date in gid 123 with custom fields/,
                 e.message)
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_greater_than_or_equal_to_n_days_from_now
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      expect_tasks_not_mocked
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?,
                                                    [:custom_field, 'start date'],
                                                    [:greater_than_or_equal_to_n_days_from_now,
                                                     90]]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_greater_than_or_equal_to_n_days_from_now_nil
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      expect_tasks_not_mocked
      task.expects(:custom_fields).returns([{ 'name' => 'start date',
                                              'display_value' => nil }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, [:custom_field, 'start date'],
                                                    [:greater_than_or_equal_to_n_days_from_now, 90]]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_greater_than_or_equal_to_n_days_from_now_custom_field_not_found
    task_selectors = get_test_object do
      expect_tasks_not_mocked
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:gid).returns('123')
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:in_period?, [:custom_field, 'start date'],
                                               [:greater_than_or_equal_to_n_days_from_now, 90]])
    end

    assert_match(/Could not find custom field with name start date in gid 123 with custom fields/,
                 e.message)
  end

  # @return [void]
  def mock_filter_via_task_selector_modified_less_than_n_days_ago
    expect_tasks_not_mocked
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
    task.expects(:modified_at).returns(Time.new(1999, 12, 1, 0, 0, 0, '+00:00').to_s).at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_modified_less_than_n_days_ago
    task_selectors = get_test_object do
      mock_filter_via_task_selector_modified_less_than_n_days_ago
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, :modified,
                                                    [:less_than_n_days_ago, 7]]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => 960 }]).at_least(1)
      task.expects(:start_on).returns('2000-01-01').at_least(1)
      task.expects(:due_on).returns('2000-01-01').at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration?]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_false_no_estimate_set
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => nil }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration?]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_true_only_due_set
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => 960 }]).at_least(1)
      task.expects(:start_on).returns(nil).at_least(1)
      task.expects(:due_on).returns('2000-01-01').at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration?]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_true_no_dates_set
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([{ 'name' => 'Estimated time',
                                              'number_value' => 960 }]).at_least(1)
      task.expects(:start_on).returns(nil).at_least(1)
      task.expects(:due_on).returns(nil).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration?]))
  end

  # @return [void]
  def test_estimate_exceeds_duration_no_estimate_field
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:estimate_exceeds_duration?]))
  end

  # @return [void]
  def test_filter_via_task_selector_modified_less_than_n_days_ago_nil
    task_selectors = get_test_object do
      expect_tasks_not_mocked
      Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00').to_s).at_least(0)
      task.expects(:modified_at).returns(nil).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, :modified,
                                                    [:less_than_n_days_ago, 7]]))
  end

  # @return [void]
  def test_filter_via_task_selector_modified_less_than_n_days_ago_field_not_supported
    task_selectors = get_test_object do
      expect_tasks_not_mocked
    end

    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:in_period?, :bogus_at,
                                               [:less_than_n_days_ago, 7]])
    end

    assert_match(/Teach me how to handle field :bogus_at/, e.message)
  end

  # @return [void]
  def test_filter_via_task_selector_modified_less_than_n_days_ago_compound_field_not_supported
    task_selectors = get_test_object do
      expect_tasks_not_mocked
    end

    e = assert_raises(RuntimeError) do
      # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
      #   expected Asana::Resources::Task, received Mocha::Mock
      task_selectors.filter_via_task_selector(task,
                                              [:in_period?, [:bogus_compound_at],
                                               [:less_than_n_days_ago, 7]])
    end

    assert_match(/Teach me how to handle field \[:bogus_compound_at\]/, e.message)
  end

  # @return [void]
  def mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_on
    # @sg-ignore Not enough arguments to Date.new
    Date.expects(:today).returns(Date.new(2000, 1, 1)).at_least(1)
    task.expects(:due_at).returns(nil)
    # @sg-ignore Not enough arguments to Date.new
    task.expects(:due_on).returns(Date.new(2000, 1, 8).to_s).at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_on
    task_selectors = get_test_object do
      expect_tasks_not_mocked
      mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_on
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, :due,
                                                    [:greater_than_or_equal_to_n_days_from_today, 7]]))
  end

  # @return [void]
  def mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_at
    expect_tasks_not_mocked
    # @sg-ignore Not enough arguments to Date.new
    Date.expects(:today).returns(Date.new(2000, 1, 1)).at_least(0)
    task.expects(:due_at).returns(Time.new(1999, 12, 1, 0, 0, 0, '+00:00').to_s).at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_at
    task_selectors = get_test_object do
      mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_at
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, :due,
                                                    [:greater_than_or_equal_to_n_days_from_today, 7]]))
  end

  # @return [void]
  def mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_nil
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00').to_s).at_least(0)
    task.expects(:due_at).returns(nil).at_least(1)
    task.expects(:due_on).returns(nil).at_least(1)
  end

  # @return [void]
  def test_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_nil
    task_selectors = get_test_object do
      expect_tasks_not_mocked
      mock_filter_via_task_selector_field_greater_than_or_equal_to_n_days_from_today_due_nil
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_period?, :due,
                                                    [:greater_than_or_equal_to_n_days_from_today, 7]]))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_equal_to_date
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:equals?, [:custom_field_value, 'end date'], '2000-01-15']))
  end

  # @return [void]
  def test_filter_via_task_selector_custom_field_not_equal_to_date
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      task.expects(:custom_fields).returns([{ 'name' => 'end date',
                                              'display_value' => '2000-01-15' }]).at_least(1)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:equals?, [:custom_field_value, 'end date'], '2001-01-15']))
  end

  # @return [void]
  def test_filter_via_task_selector_last_story_created_less_than_n_days_ago_no_stories
    task_selectors = get_test_object do
      task.expects(:stories).returns([])
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:last_story_created_less_than_n_days_ago?, 7, []]))
  end

  # @return [void]
  def mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_ancient
    # @sg-ignore Unresolved call to story
    task.expects(:stories).returns([story])
    # @sg-ignore Unresolved call to story
    story.expects(:resource_subtype).returns('blah')
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
    # @sg-ignore Unresolved call to story
    story.expects(:created_at).returns(Time.new(1950, 1, 1, 0, 0, 0, '+00:00').to_s)
  end

  # @return [void]
  def test_filter_via_task_selector_last_story_created_less_than_n_days_ago_ancient
    task_selectors = get_test_object do
      mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_ancient
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:last_story_created_less_than_n_days_ago?, 7, []]))
  end

  # @return [void]
  def mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_recent
    # @sg-ignore Unresolved call to story
    task.expects(:stories).returns([story])
    # @sg-ignore Unresolved call to story
    story.expects(:resource_subtype).returns('blah')
    Time.expects(:now).returns(Time.new(2000, 1, 1, 0, 0, 0, '+00:00')).at_least(1)
    # @sg-ignore Unresolved call to story
    story.expects(:created_at).returns(Time.new(1999, 12, 31, 0, 0, 0, '+00:00').to_s)
  end

  # @return [void]
  def test_filter_via_task_selector_last_story_created_less_than_n_days_ago_recent
    task_selectors = get_test_object do
      mock_filter_via_task_selector_last_story_created_less_than_n_days_ago_recent
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:last_story_created_less_than_n_days_ago?, 7, []]))
  end

  # @return [void]
  def test_filter_via_task_selector_in_project_named_false
    task_selectors = get_test_object do
      task.expects(:memberships).returns([])
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_project_named?, 'foo']))
  end

  # @return [void]
  def test_filter_via_task_selector_in_project_named_true
    task_selectors = get_test_object do
      task.expects(:memberships).returns([{ 'project' => { 'name' => 'foo' } }])
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_project_named?, 'foo']))
  end

  # @return [void]
  def test_filter_via_task_selector_in_section_named_false
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_section_name' => {} }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_section_named?, 'foo']))
  end

  # @return [void]
  def test_filter_via_task_selector_in_section_named_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_section_name' => { 'foo' => {}, 'bar' => {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_section_named?, 'foo']))
  end

  # @return [void]
  def test_dependent_on_previous_section_last_milestone
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to timelines
      timelines
        .expects(:task_dependent_on_previous_section_last_milestone?)
        .with(task,
              limit_to_portfolio_gid: nil).returns(true)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:dependent_on_previous_section_last_milestone?]))
  end

  # @return [void]
  def test_in_portfolio_named_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:in_portfolio_named?).with(task, 'foo').returns(true)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task,
                                                   [:in_portfolio_named?, 'foo']))
  end

  # @return [void]
  def test_in_portfolio_named_false
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:in_portfolio_named?).with(task, 'foo').returns(false)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:in_portfolio_named?, 'foo']))
  end

  # @return [void]
  def test_custom_field_gid_value_contains_any_gid_false_multi_enum
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [
        {
          # @sg-ignore Unresolved call to custom_field_gid
          'gid' => custom_field_gid,
          'resource_subtype' => 'multi_enum',
          'multi_enum_values' => [],
        },
      ]
      task.expects(:custom_fields).returns(custom_fields)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:custom_field_gid_value_contains_any_gid?,
                                                    # @sg-ignore Unresolved call to custom_field_gid
                                                    # @sg-ignore Unresolved call to custom_field_value_gid_1
                                                    custom_field_gid, [custom_field_value_gid_1]]))
  end

  # @return [void]
  def test_last_task_milestone_does_not_depend_on_this_task
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to timelines
      timelines.expects(:last_task_milestone_depends_on_this_task?).returns(true)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task,
                                                   [:last_task_milestone_does_not_depend_on_this_task?]))
  end

  # @return [void]
  def test_in_a_real_project_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_project_name' => { 'Real Project' => {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_a_real_project?]))
  end

  # @return [void]
  def test_in_a_real_project_false_only_my_tasks
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_project_name' => { my_tasks: {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:in_a_real_project?]))
  end

  # @return [void]
  def test_section_name_starts_with_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_section_name' => { 'Done items' => {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:section_name_starts_with?, 'Done']))
  end

  # @return [void]
  def test_section_name_starts_with_false
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_section_name' => { 'Inbox' => {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:section_name_starts_with?, 'Done']))
  end

  # @return [void]
  def test_in_section_named_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_section_name' => { 'Today' => {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_section_named?, 'Today']))
  end

  # @return [void]
  def test_in_section_named_false
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(
        'unwrapped' => { 'membership_by_section_name' => { 'Today' => {} } }
      )
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    refute(task_selectors.filter_via_task_selector(task, [:in_section_named?, 'Tomorrow']))
  end

  # @return [void]
  def test_in_portfolio_more_than_once_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:in_portfolio_more_than_once?).with(task, 'portfolio').returns(true)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:in_portfolio_more_than_once?, 'portfolio']))
  end

  # @return [void]
  def test_no_milestone_depends_on_this_task_true
    task_selectors = get_test_object do
      # @sg-ignore Unresolved call to timelines
      timelines.expects(:any_milestone_depends_on_this_task?)
        .with(task, limit_to_portfolio_name: nil).returns(false)
    end

    # @sg-ignore Wrong argument type for Checkoff::TaskSelectors#filter_via_task_selector: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    assert(task_selectors.filter_via_task_selector(task, [:no_milestone_depends_on_this_task?]))
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      clients: Checkoff::Clients,
      client: Asana::Client,
      tasks: Checkoff::Tasks,
      timelines: Checkoff::Timelines,
      custom_fields: Checkoff::CustomFields,
    }
  end

  def respond_like
    {}
  end

  # @return [Class<Checkoff::TaskSelectors>]
  def class_under_test
    Checkoff::TaskSelectors
  end
end
# rubocop:enable Metrics/ClassLength
