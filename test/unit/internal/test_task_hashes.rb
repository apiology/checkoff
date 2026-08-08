# typed: false
# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/task_hashes'

class TestTaskHashes < ClassTest
  typed_mock :task, Asana::Resources::Task

  MEMBER_OF_SECTION_A_IN_PROJECT_1 = {
    'section' => {
      'gid' => 'section_a_gid',
      'name' => 'section_a_name',
    },
    'project' => {
      'gid' => 'project_1_gid',
      'name' => 'project_1_name',
    },
  }.freeze

  TASK_A_RAW_HASH = {
    'name' => 'a',
    'custom_fields' => [
      {
        'name' => 'custom_field_x',
        'display_value' => 'foo',
      },
    ],
    'memberships' => [
      MEMBER_OF_SECTION_A_IN_PROJECT_1,
    ],
  }.freeze

  TASK_A_HASH = {
    'name' => 'a',
    'task' => 'a',
    'custom_fields' => [
      { 'name' => 'custom_field_x', 'display_value' => 'foo' },
    ],
    'memberships' => [
      MEMBER_OF_SECTION_A_IN_PROJECT_1,
    ],
    'unwrapped' => {
      'custom_fields' => {
        'custom_field_x' => {
          'name' => 'custom_field_x',
          'display_value' => 'foo',
        },
      },
      'membership_by_section_gid' => {
        'section_a_gid' => MEMBER_OF_SECTION_A_IN_PROJECT_1,
      },
      'membership_by_section_name' => {
        'section_a_name' => MEMBER_OF_SECTION_A_IN_PROJECT_1,
      },
      'membership_by_project_gid' => {
        'project_1_gid' => MEMBER_OF_SECTION_A_IN_PROJECT_1,
      },
      'membership_by_project_name' => {
        'project_1_name' => MEMBER_OF_SECTION_A_IN_PROJECT_1,
      },
    },
  }.freeze

  TASK_B_RAW_HASH = {
    'name' => 'b',
    'custom_fields' => [
      {
        'name' => 'custom_field_x',
        'display_value' => 'bar',
      },
    ],
  }.freeze

  TASK_B_HASH = {
    'name' => 'b',
    'task' => 'b',
    'custom_fields' => [
      { 'name' => 'custom_field_x', 'display_value' => 'bar' },
    ],
    'unwrapped' => {
      'custom_fields' => {
        'custom_field_x' => { 'name' => 'custom_field_x', 'display_value' => 'bar' },
      },
      'membership_by_section_gid' => {},
      'membership_by_section_name' => {},
      'membership_by_project_gid' => {},
      'membership_by_project_name' => {},
    },
  }.freeze

  TASK_C_RAW_HASH = {
    'name' => 'c',
    'assignee_section' => {
      'gid' => 'assignee_section_gid',
      'name' => 'assignee_section_name',
    },
    'assignee' => {
      'gid' => 'assignee_gid',
      'name' => 'assignee_name',
    },
  }.freeze

  ASSIGNEE_MEMBERSHIP = {
    'section' => {
      'gid' => 'assignee_section_gid',
      'name' => 'assignee_section_name',
    },
    'project' => {
      'gid' => 'assignee_gid',
      'name' => :my_tasks,
    },
  }.freeze

  TASK_C_HASH = {
    'name' => 'c',
    'task' => 'c',
    'assignee_section' => {
      'gid' => 'assignee_section_gid',
      'name' => 'assignee_section_name',
    },
    'assignee' => {
      'gid' => 'assignee_gid',
      'name' => 'assignee_name',
    },
    'unwrapped' => {
      'membership_by_section_gid' => {
        'assignee_section_gid' => ASSIGNEE_MEMBERSHIP,
      },
      'membership_by_section_name' => {
        'assignee_section_name' => ASSIGNEE_MEMBERSHIP,
      },
      'membership_by_project_gid' => {
        'assignee_gid' => ASSIGNEE_MEMBERSHIP,
      },
      'membership_by_project_name' => {
        my_tasks: ASSIGNEE_MEMBERSHIP,
      },
    },
  }.freeze

  # @return [void]
  def test_task_a_to_h
    task_hashes = get_test_object(Checkoff::Internal::TaskHashes) do
      task.expects(:to_h).returns(TASK_A_RAW_HASH.dup)
      task.expects(:name).returns('a')
    end

    assert_equal(TASK_A_HASH, task_hashes.task_to_h(task))
  end

  # @return [void]
  def test_task_b_to_h
    task_hashes = get_test_object(Checkoff::Internal::TaskHashes) do
      task.expects(:to_h).returns(TASK_B_RAW_HASH.dup)
      task.expects(:name).returns('b')
    end

    assert_equal(TASK_B_HASH, task_hashes.task_to_h(task))
  end

  # @return [void]
  def test_task_c_to_h_assignee_section
    task_hashes = get_test_object(Checkoff::Internal::TaskHashes) do
      task.expects(:to_h).returns(TASK_C_RAW_HASH.dup)
      task.expects(:name).returns('c')
    end

    assert_equal(TASK_C_HASH, task_hashes.task_to_h(task))
  end

  # @return [void]
  def test_assignee_hash_not_a_hash
    task_hashes = get_test_object(Checkoff::Internal::TaskHashes)

    e = assert_raises(RuntimeError) do
      task_hashes.send(:assignee_hash, { 'assignee' => 'not a hash' })
    end
    assert_match(/Expected assignee to be a Hash, got String/, e.message)
  end
end
