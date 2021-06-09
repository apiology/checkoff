# frozen_string_literal: true

require_relative 'base_asana'
require 'checkoff/cli'

# Test the Checkoff::Tasks class
class TestTasks < BaseAsana
  extend Forwardable

  def_delegators :@mocks, :sections

  let_mock :mock_tasks, :modified_mock_tasks, :tasks_by_section,
           :unflattened_modified_mock_tasks

  def mock_tasks_minus_sections
    @mocks[:sections]
      .expects(:by_section).with(mock_tasks)
      .returns(tasks_by_section)
    tasks_by_section.expects(:values).returns(unflattened_modified_mock_tasks)
    unflattened_modified_mock_tasks
      .expects(:flatten).returns(modified_mock_tasks)
  end

  def test_tasks_minus_sections
    tasks = get_test_object do
      mock_tasks_minus_sections
    end
    assert_equal(modified_mock_tasks,
                 tasks.send(:tasks_minus_sections, mock_tasks))
  end

  let_mock :workspace_gid, :task_name, :default_assignee_gid

  def expect_task_created
    @mocks[:asana_task].expects(:create).with(client,
                                              assignee: default_assignee_gid,
                                              workspace: workspace_gid,
                                              name: task_name)
  end

  def mock_add_task
    @mocks[:config].expects(:fetch).with(:default_assignee_gid)
      .returns(default_assignee_gid)
    @mocks[:sections].expects(:client).returns(client)
    expect_task_created
  end

  def test_add_task
    tasks = get_test_object do
      mock_add_task
    end
    tasks.send(:add_task, task_name, workspace_gid: workspace_gid)
  end

  let_mock :workspace_name, :project_name, :task_name, :only_uncompleted, :task,
           :projects, :project

  def expect_tasks_from_project_pulled
    projects.expects(:tasks_from_project)
      .with(project, only_uncompleted: only_uncompleted)
      .returns([task])
    task.expects(:name).returns(task_name)
  end

  def expect_project_pulled
    projects.expects(:project).with(workspace_name, project_name)
      .returns(project)
  end

  def expect_projects_pulled
    sections.expects(:projects).returns(projects)
  end

  def mock_task
    expect_projects_pulled
    expect_project_pulled
    expect_tasks_from_project_pulled
  end

  def test_task
    tasks = get_test_object { mock_task }
    returned_task = tasks.task(workspace_name, project_name, task_name,
                               only_uncompleted: only_uncompleted)
    assert_equal(task, returned_task)
  end

  def class_under_test
    Checkoff::Tasks
  end
end
