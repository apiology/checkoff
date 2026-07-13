# typed: false
# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/project_hashes'

class TestProjectHashes < ClassTest
  let_mock :project

  PROJECT_A_RAW_HASH = {
    'name' => 'a',
    'custom_fields' => [
      {
        'name' => 'custom_field_x',
        'display_value' => 'foo',
      },
    ],
  }.freeze

  PROJECT_A_HASH = {
    'name' => 'a',
    'project' => 'a',
    'custom_fields' => [
      { 'name' => 'custom_field_x', 'display_value' => 'foo' },
    ],
    'unwrapped' => {
      'custom_fields' => {
        'custom_field_x' => {
          'name' => 'custom_field_x',
          'display_value' => 'foo',
        },
      },
    },
  }.freeze

  PROJECT_B_RAW_HASH = {
    'name' => 'b',
    'custom_fields' => [
      {
        'name' => 'custom_field_x',
        'display_value' => 'bar',
      },
    ],
  }.freeze

  PROJECT_B_HASH = {
    'name' => 'b',
    'project' => 'b',
    'custom_fields' => [
      { 'name' => 'custom_field_x', 'display_value' => 'bar' },
    ],
    'unwrapped' => {
      'custom_fields' => {
        'custom_field_x' => { 'name' => 'custom_field_x', 'display_value' => 'bar' },
      },
    },
  }.freeze

  # @return [void]
  def test_project_a_to_h
    project_hashes = get_test_object do
      # @sg-ignore project from let_mock
      project.expects(:to_h).returns(PROJECT_A_RAW_HASH.dup)
      # @sg-ignore project from let_mock
      project.expects(:name).returns('a')
    end

    # @sg-ignore project from let_mock; project_to_h return is opaque here
    assert_equal(PROJECT_A_HASH, project_hashes.project_to_h(project))
  end

  # @return [void]
  def test_project_b_to_h
    project_hashes = get_test_object do
      # @sg-ignore project from let_mock
      project.expects(:to_h).returns(PROJECT_B_RAW_HASH.dup)
      # @sg-ignore project from let_mock
      project.expects(:name).returns('b')
    end

    # @sg-ignore project from let_mock
    assert_equal(PROJECT_B_HASH, project_hashes.project_to_h(project))
  end

  # @return [void]
  def test_project_b_to_h_named
    project_hashes = get_test_object do
      # @sg-ignore project from let_mock
      project.expects(:to_h).returns(PROJECT_B_RAW_HASH.dup)
    end

    # @sg-ignore project from let_mock
    project_data = project_hashes.project_to_h(project, project: :my_tasks)

    # @sg-ignore project_to_h hash value access
    assert_equal(:my_tasks, project_data['project'])
  end

  # @return [Class]
  def class_under_test
    Checkoff::Internal::ProjectHashes
  end
end
