# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Projects class
class TestProjects < BaseAsana
  def setup_config
    @mocks[:config] = {
      personal_access_token: personal_access_token,
      my_tasks: { 'My Workspace' => my_tasks_in_workspace_id },
    }
  end

  def setup_projects_pulled
    client.expects(:projects).returns(projects).at_least(1)
  end

  let_mock :workspaces, :workspace_workspace, :some_other_workspace,
           :workspace_1, :workspace_1_id, :my_workspace_id, :n, :workspace_name,
           :all_workspaces, :my_tasks_project, :tasks, :task_a, :task_b

  def sample_projects
    { project_a => a_name, project_b => b_name, project_c => c_name }
  end

  def setup_projects_queried(workspace_id: my_workspace_id)
    projects
      .expects(:find_by_workspace).with(workspace: workspace_id)
      .returns(sample_projects.keys)
    sample_projects.each do |project, name|
      project.expects(:name).returns(name).at_least(0)
    end
  end

  def setup_client_pulled
    @mocks[:workspaces].expects(:client).returns(client)
  end

  def mock_tasks_from_project
    setup_config
    setup_client_pulled
    project_a.expects(:id).returns(a_id)
    client.expects(:tasks).returns(tasks)
    options = task_options
    options[:project] = a_id
    tasks.expects(:find_all).with(options).returns(tasks)
    tasks.expects(:to_a).returns(tasks)
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
                       .with('Workspace 1').returns(workspace_1)
    workspace_1.expects(:id).returns(workspace_1_id)
  end

  def test_project_regular
    asana = get_test_object do
      setup_config
      setup_client_pulled
      setup_workspace_pulled
      setup_projects_pulled
      setup_projects_queried(workspace_id: workspace_1_id)
    end
    assert_equal(project_a, asana.project('Workspace 1', a_name))
  end

  def test_project_my_tasks
    asana = get_test_object do
      setup_config
      setup_client_pulled
      setup_projects_pulled
      projects
        .expects(:find_by_id).with(my_tasks_in_workspace_id)
        .returns(my_tasks_project)
    end
    assert_equal(my_tasks_project, asana.project('My Workspace', :my_tasks))
  end

  let_mock :my_tasks_config

  def unconfigured_workspace_name
    'Unconfigured workspace name'
  end

  def test_project_my_tasks_not_configured
    asana = get_test_object do
      @mocks[:config].expects(:[]).with(:my_tasks).returns(my_tasks_config)
                     .at_least(1)
      my_tasks_config.expects(:[]).with(unconfigured_workspace_name)
                     .returns(nil)
    end
    e = assert_raises do
      asana.my_tasks(unconfigured_workspace_name)
    end
    assert_equal('Please define [:my_tasks][Unconfigured workspace name] in config file',
                 e.message)
  end

  def class_under_test
    Checkoff::Projects
  end
end
