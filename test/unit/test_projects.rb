# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Projects class
class TestProjects < BaseAsana
  def setup_config
    @mocks[:config] = { personal_access_token: personal_access_token }
  end

  def setup_projects_pulled
    client.expects(:projects).returns(projects).at_least(1)
  end

  let_mock :workspaces, :workspace_workspace, :some_other_workspace,
           :workspace_one, :workspace_one_gid, :my_workspace_gid, :n,
           :workspace_name, :all_workspaces, :my_tasks_project, :tasks,
           :task_a, :task_b, :user_task_lists, :user_task_list

  def sample_projects
    { project_a => a_name, project_b => b_name, project_c => c_name }
  end

  def setup_projects_queried(workspace_gid: my_workspace_gid)
    projects
      .expects(:find_by_workspace).with(workspace: workspace_gid)
      .returns(sample_projects.keys)
    sample_projects.each do |project, name|
      project.expects(:name).returns(name).at_least(0)
    end
  end

  def setup_client_pulled
    @mocks[:workspaces].expects(:client).returns(client).at_least(1)
  end

  def expect_tasks_found
    options = task_options
    options[:project] = a_gid
    tasks.expects(:find_all).with(options).returns(tasks)
    tasks.expects(:to_a).returns(tasks)
  end

  def mock_tasks_from_project
    setup_config
    setup_client_pulled
    project_a.expects(:gid).returns(a_gid)
    client.expects(:tasks).returns(tasks)
    expect_tasks_found
  end

  def test_tasks_from_project
    asana = get_test_object do
      mock_tasks_from_project
    end
    assert_equal(tasks, asana.tasks_from_project(project_a))
  end

  def test_active_tasks
    asana = get_test_object do
      task_a.expects(:completed_at).returns(mock_now)
      task_b.expects(:completed_at).returns(nil)
    end
    assert_equal([task_b], asana.active_tasks([task_a, task_b]))
  end

  def setup_workspace_pulled
    @mocks[:workspaces].expects(:workspace_by_name)
      .with('Workspace 1').returns(workspace_one)
    workspace_one.expects(:gid).returns(workspace_one_gid)
  end

  def test_project_regular
    asana = get_test_object do
      setup_config
      setup_client_pulled
      setup_workspace_pulled
      setup_projects_pulled
      setup_projects_queried(workspace_gid: workspace_one_gid)
    end
    assert_equal(project_a, asana.project('Workspace 1', a_name))
  end

  def setup_user_task_list_pulled
    client.expects(:user_task_lists).returns(user_task_lists)
    user_task_lists.expects(:get_user_task_list_for_user)
      .with(user_gid: 'me', workspace: workspace_one_gid)
      .returns(user_task_list)
    user_task_list.expects(:gid).returns(my_tasks_in_workspace_gid)
  end

  def mock_project_my_tasks
    setup_config
    setup_client_pulled
    setup_workspace_pulled
    setup_projects_pulled
    setup_user_task_list_pulled
    projects
      .expects(:find_by_id).with(my_tasks_in_workspace_gid)
      .returns(my_tasks_project)
  end

  def test_project_my_tasks
    asana = get_test_object do
      mock_project_my_tasks
    end
    assert_equal(my_tasks_project, asana.project('Workspace 1', :my_tasks))
  end

  let_mock :my_tasks_config

  def unconfigured_workspace_name
    'Unconfigured workspace name'
  end

  def mock_project_my_tasks_not_configured
    @mocks[:config].expects(:fetch).with(:my_tasks).returns(my_tasks_config)
      .at_least(1)
    my_tasks_config.expects(:[]).with(unconfigured_workspace_name).returns(nil)
  end

  def class_under_test
    Checkoff::Projects
  end
end
