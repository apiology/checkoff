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

  def setup_client_created
    @mocks[:asana_client].expects(:new).yields(client).returns(client)
    client.expects(:authentication).with(:access_token, personal_access_token)
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

  def setup_workspaces_pulled
    client.expects(:workspaces).returns(workspaces)
  end

  def expect_workspaces_found(all_workspaces)
    workspaces.expects(:find_all).returns(all_workspaces)
  end

  def expect_workspace_described(workspace, name, id)
    workspace.expects(:name).returns(name).at_least(0)
    workspace.expects(:id).returns(id).at_least(0)
  end

  def setup_all_workspaces_pulled
    setup_workspaces_pulled
    expect_workspaces_found([workspace_workspace, some_other_workspace,
                             workspace_1])
    expect_workspace_described(workspace_workspace, 'My Workspace',
                               my_workspace_id)
    some_other_workspace
      .expects(:name).returns('Some other workspace')
      .at_least(0)
    expect_workspace_described(workspace_1, 'Workspace 1', workspace_1_id)
  end

  def mock_tasks_from_project
    project_a.expects(:tasks).with(task_options).returns(tasks)
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

  def test_project_regular
    asana = get_test_object do
      setup_config
      setup_client_created
      setup_all_workspaces_pulled
      setup_projects_pulled
      setup_projects_queried(workspace_id: workspace_1_id)
    end
    assert_equal(project_a, asana.project('Workspace 1', a_name))
  end

  def test_project_my_tasks
    asana = get_test_object do
      setup_config
      setup_client_created
      setup_projects_pulled
      projects
        .expects(:find_by_id).with(my_tasks_in_workspace_id)
        .returns(my_tasks_project)
    end
    assert_equal(my_tasks_project, asana.project('My Workspace', :my_tasks))
  end

  def class_under_test
    Checkoff::Projects
  end
end
