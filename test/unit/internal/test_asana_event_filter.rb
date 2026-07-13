# typed: false
# frozen_string_literal: true

require_relative '../class_test'
require 'checkoff/internal/asana_event_filter'

class TestAsanaEventFilter < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client, :tasks)

  let_mock :task, :asana_tasks

  # @return [void]
  def test_matches_nil_filters_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = nil
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?([{}]))
  end

  # @return [void]
  def test_matches_zero_filters_false
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = []
    end

    # @sg-ignore Unresolved call to matches?
    refute(asana_event_filter.matches?({}))
  end

  # @return [void]
  def test_matches_on_resource_type_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'resource_type' => 'task' }]
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?({ 'resource' => { 'resource_type' => 'task' } }))
  end

  # @return [void]
  def test_matches_on_resource_subtype_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'resource_subtype' => 'milestone' }]
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?({ 'resource' => { 'resource_subtype' => 'milestone' } }))
  end

  # @return [void]
  def test_matches_on_action_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'action' => 'deleted' }]
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?({ 'action' => 'deleted' }))
  end

  # @return [void]
  def test_matches_on_action_false
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'action' => 'deleted' }]
    end

    # @sg-ignore Unresolved call to matches?
    refute(asana_event_filter.matches?({ 'action' => 'completed' }))
  end

  TASK_NAME_CHANGED_EVENT = {
    'action' => 'changed',
    'created_at' => '2024-01-16T20:10:27.783Z',
    'change' => {
      'field' => 'name',
      'action' => 'changed',
    },
    'resource' => {
      'gid' => '456',
      'resource_type' => 'task',
      'resource_subtype' => 'default_task',
    },
    'user' => {
      'gid' => '123',
      'resource_type' => 'user',
    },
  }.freeze

  CUSTOM_FIELD_CHANGED_EVENT = {
    'action' => 'changed',
    'created_at' => '2023-11-23T18:00:00.271Z',
    'change' => {
      'field' => 'custom_fields',
      'action' => 'changed',
      'new_value' => {
        'gid' => '12',
        'resource_type' => 'custom_field',
        'resource_subtype' => 'enum',
        'enum_value' => {
          'gid' => '34',
          'resource_type' => 'enum_option',
        },
      },
    },
    'resource' => {
      'gid' => '56',
      'resource_type' => 'task',
      'resource_subtype' => 'default_task',
    },
    'user' => {
      'gid' => '78',
      'resource_type' => 'user',
    },
  }.freeze

  TASK_REMOVED_FROM_SECTION_EVENT = {
    'action' => 'removed',
    'created_at' => '2023-11-22T21:42:14.029Z',
    'parent' => {
      'gid' => '90',
      'resource_type' => 'section',
    },
    'resource' => {
      'gid' => '1',
      'resource_type' => 'task',
      'resource_subtype' => 'default_task',
    },
    'user' => {
      'gid' => '78',
      'resource_type' => 'user',
    },
  }.freeze

  TASK_COMPLETED_EVENT = {
    'user' => {
      'gid' => '123',
      'resource_type' => 'user',
    },
    'created_at' => '2024-01-13T20:51:41.806Z',
    'action' => 'changed',
    'resource' => {
      'gid' => '456',
      'resource_type' => 'task',
      'resource_subtype' => 'default_task',
    },
    'parent' => nil,
    'change' => { 'field' => 'completed', 'action' => 'changed' },
  }.freeze

  TASK_COMPLETED_EVENT_2 = {
    'user' => {
      'gid' => '123',
      'resource_type' => 'user',
    },
    'created_at' => '2024-01-15T12:34:45.332Z',
    'action' => 'changed',
    'resource' => {
      'gid' => '456',
      'resource_type' => 'task',
      'resource_subtype' => 'default_task',
    },
    'change' => {
      'field' => 'completed',
      'action' => 'changed',
    },
  }.freeze

  # @return [void]
  def test_fetched_section_gid
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'checkoff:fetched.section.gid' => '123' }]
      expect_task_fetched('456',
                          ['memberships.project.gid', 'memberships.project.name',
                           'memberships.section.name', 'assignee', 'assignee_section'],
                          # @sg-ignore Unresolved call to task
                          task)
      task_data = {
        'unwrapped' => {
          'membership_by_section_gid' => {
            '123' => {},
          },
        },
      }
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task_to_h).with(task).returns(task_data)
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?(TASK_NAME_CHANGED_EVENT))
  end

  # @return [void]
  def test_matches_on_fields_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'fields' => ['custom_fields'] }]
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?(CUSTOM_FIELD_CHANGED_EVENT))
  end

  # @return [void]
  # @param gid [Object]
  # @param task_obj [Object]
  # @param fields [Object]
  def expect_task_fetched(gid, fields, task_obj)
    # @sg-ignore Unresolved call to client
    client.expects(:tasks).returns(asana_tasks)
    # @sg-ignore Unresolved call to asana_tasks
    asana_tasks
      .expects(:find_by_id)
      .with(gid,
            options: { fields: })
      .returns(task_obj)
  end

  # @return [void]
  def test_task_completed_event_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [
        {
          'action' => 'changed',
          'fields' => ['completed'],
          'resource_type' => 'task',
          'checkoff:resource.gid' => '456',
          'checkoff:fetched.completed' => true,
        },
      ]
      # @sg-ignore Unresolved call to task
      expect_task_fetched('456', ['completed_at'], task)
      # @sg-ignore Unresolved call to task
      task.expects(:completed_at).returns(Time.now)
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?(TASK_COMPLETED_EVENT))
  end

  # @return [void]
  def test_matches_on_parent_gid_true
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'checkoff:parent.gid' => '90' }]
    end

    # @sg-ignore Unresolved call to matches?
    assert(asana_event_filter.matches?(TASK_REMOVED_FROM_SECTION_EVENT))
  end

  # @return [void]
  def test_matches_on_bad_key_raises
    asana_event_filter = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:filters] = [{ 'checkoff:bogus' => '90' }]
    end
    e = assert_raises(RuntimeError) do
      # @sg-ignore Unresolved call to matches?
      asana_event_filter.matches?(TASK_REMOVED_FROM_SECTION_EVENT)
    end

    assert_match(/Unknown filter key checkoff:bogus/, e.message)
  end

  # @return [void]
  def class_under_test
    Checkoff::Internal::AsanaEventFilter
  end

  def respond_like_instance_of
    {
      filters: Array,
      clients: Checkoff::Clients,
      tasks: Checkoff::Tasks,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
