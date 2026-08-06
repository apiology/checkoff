# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'checkoff/my_tasks'

# Test the Checkoff::MyTasks class
class TestMyTasks < BaseAsana
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::MyTasks]
  #  def get_test_object; end

  def_delegators(:@mocks, :client)

  typed_mock :sections, Asana::ProxiedResourceClasses::Section
  typed_mock :section_1, Asana::Resources::Section
  typed_mock :project_gid, String

  # @return [void]
  def mock_sections_for_project
    client.expects(:sections).returns(sections).at_least(1)
    sections.expects(:get_sections_for_project)
      .with(project_gid:, options: { fields: ['name'] })
      .returns([section_1])
    section_1.expects(:name).returns('Section 1').at_least(1)
  end

  # @return [void]
  def mock_by_my_tasks_section
    mock_sections_for_project
    task_a.expects(:assignee_section).returns(section_1)
    task_b.expects(:assignee_section).returns(nil)
  end

  # @return [void]
  def test_by_my_tasks_section_groups_by_assignee_section
    my_tasks = get_test_object do
      mock_by_my_tasks_section
    end

    result = my_tasks.by_my_tasks_section([task_a, task_b], project_gid)

    assert_equal([task_a], result.fetch('Section 1'))
    assert_equal([task_b], result.fetch(nil))
  end

  # @return [void]
  def respond_like_instance_of
    {
      config: Hash,
      client: Asana::Client,
      projects: Checkoff::Projects,
    }
  end

  # @return [void]
  def respond_like
    {}
  end

  # @return [Class]
  def class_under_test
    Checkoff::MyTasks
  end
end
