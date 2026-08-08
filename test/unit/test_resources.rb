# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/resources'

class TestResources < ClassTest
  typed_delegate :tasks, Checkoff::Tasks
  typed_delegate :sections, Checkoff::Sections
  typed_delegate :projects, Checkoff::Projects

  typed_mock :gid, String
  typed_mock :task, Asana::Resources::Task
  typed_mock :section, Asana::Resources::Section
  typed_mock :project, Asana::Resources::Project

  # @return [void]
  def expect_task_not_found
    tasks.expects(:task_by_gid).with(gid, only_uncompleted: false).returns(nil)
  end

  # @return [void]
  def expect_section_not_found
    sections.expects(:section_by_gid).with(gid).returns(nil)
  end

  # @return [void]
  def test_resource_by_gid_task_found
    resources = get_test_object(Checkoff::Resources) do
      tasks.expects(:task_by_gid).with(gid, only_uncompleted: false).returns(task)
    end

    assert_equal([task, 'task'], resources.resource_by_gid(gid))
  end

  # @return [void]
  def test_resource_by_gid_falls_through_to_project
    resources = get_test_object(Checkoff::Resources) do
      expect_task_not_found
      expect_section_not_found
      projects.expects(:project_by_gid).with(gid).returns(project)
    end

    assert_equal([project, 'project'], resources.resource_by_gid(gid))
  end

  # @return [void]
  def test_resource_by_gid_not_found
    resources = get_test_object(Checkoff::Resources) do
      expect_task_not_found
      expect_section_not_found
      projects.expects(:project_by_gid).with(gid).returns(nil)
    end

    assert_equal([nil, nil], resources.resource_by_gid(gid))
  end

  # @return [void]
  def test_resource_by_gid_resource_type_provided
    resources = get_test_object(Checkoff::Resources) do
      sections.expects(:section_by_gid).with(gid).returns(section)
    end

    assert_equal([section, 'section'], resources.resource_by_gid(gid, resource_type: 'section'))
  end

  # @return [void]
  def test_fetch_gid_by_type_unexpected_resource_type
    resources = get_test_object(Checkoff::Resources)

    e = assert_raises(RuntimeError) do
      resources.send(:fetch_gid_by_type, 'bogus', gid)
    end
    assert_match(/Unexpected resource_type: bogus/, e.message)
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      tasks: Checkoff::Tasks,
      sections: Checkoff::Sections,
      projects: Checkoff::Projects,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
