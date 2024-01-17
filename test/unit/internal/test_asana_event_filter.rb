# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/asana_event_filter'

class TestAsanaEventFilter < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client, :tasks)

  let_mock :task, :asana_tasks

  def test_matches_nil_filters_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = nil
    end

    assert(asana_event_filter.matches?([{}]))
  end

  def test_matches_zero_filters_false
    asana_event_filter = get_test_object do
      @mocks[:filters] = []
    end

    refute(asana_event_filter.matches?({}))
  end

  def test_matches_on_resource_type_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'resource_type' => 'task' }]
    end

    assert(asana_event_filter.matches?({ 'resource' => { 'resource_type' => 'task' } }))
  end

  def test_matches_on_resource_subtype_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'resource_subtype' => 'milestone' }]
    end

    assert(asana_event_filter.matches?({ 'resource' => { 'resource_subtype' => 'milestone' } }))
  end

  def test_matches_on_action_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'action' => 'deleted' }]
    end

    assert(asana_event_filter.matches?({ 'action' => 'deleted' }))
  end

  def test_matches_on_action_false
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'action' => 'deleted' }]
    end

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

  def test_fetched_section_gid
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'checkoff:fetched.section.gid' => '123' }]
      expect_task_fetched('456', ['memberships.section.gid', 'assignee', 'assignee_section'], task)
      task_data = {
        'membership_by_section_gid' => {
          '123' => {},
        },
      }
      tasks.expects(:task_to_h).with(task).returns(task_data)
    end

    assert(asana_event_filter.matches?(TASK_NAME_CHANGED_EVENT))
  end

  def test_matches_on_fields_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'fields' => ['custom_fields'] }]
    end

    assert(asana_event_filter.matches?(CUSTOM_FIELD_CHANGED_EVENT))
  end

  def expect_task_fetched(gid, fields, task_obj)
    client.expects(:tasks).returns(asana_tasks)
    asana_tasks
      .expects(:find_by_id)
      .with(gid,
            options: { fields: fields })
      .returns(task_obj)
  end

  def test_task_completed_event_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = [
        {
          'action' => 'changed',
          'fields' => ['completed'],
          'resource_type' => 'task',
          'checkoff:resource.gid' => '456',
          'checkoff:fetched.completed' => true,
        },
      ]
      expect_task_fetched('456', ['completed_at'], task)
      task.expects(:completed_at).returns(Time.now)
    end

    assert(asana_event_filter.matches?(TASK_COMPLETED_EVENT))
  end

  def test_matches_on_parent_gid_true
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'checkoff:parent.gid' => '90' }]
    end

    assert(asana_event_filter.matches?(TASK_REMOVED_FROM_SECTION_EVENT))
  end

  def test_matches_on_bad_key_raises
    asana_event_filter = get_test_object do
      @mocks[:filters] = [{ 'checkoff:bogus' => '90' }]
    end
    e = assert_raises(RuntimeError) do
      asana_event_filter.matches?(TASK_REMOVED_FROM_SECTION_EVENT)
    end

    assert_match(/Unknown filter key checkoff:bogus/, e.message)
  end

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
