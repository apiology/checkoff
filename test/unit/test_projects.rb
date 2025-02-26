# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Projects class
class TestProjects < BaseAsana
  extend Forwardable

  def_delegators(:@mocks, :client, :project_hashes, :project_timing, :timing)

  def setup_config
    @mocks[:config] = { personal_access_token: }
  end

  def setup_projects_pulled
    client.expects(:projects).returns(projects).at_least(1)
  end

  let_mock :workspaces, :workspace_workspace, :some_other_workspace,
           :workspace_one, :workspace_one_gid, :my_workspace_gid, :n,
           :workspace_name, :all_workspaces, :my_tasks_project, :tasks,
           :task_a, :task_b, :user_task_lists, :user_task_list, :project_a_hash,
           :project, :project_gid, :client_projects, :field_name, :period,
           :returned_date

  def sample_projects
    { project_a => a_name, project_b => b_name, project_c => c_name }
  end

  def setup_projects_queried(workspace_gid: my_workspace_gid)
    projects
      .expects(:find_by_workspace).with(workspace: workspace_gid,
                                        per_page: 100,
                                        options: { fields: %w[custom_fields name] })
      .returns(sample_projects.keys)
    sample_projects.each do |project, name|
      project.expects(:name).returns(name).at_least(0)
    end
  end

  def expect_tasks_found(options:)
    options[:project] = a_gid
    tasks.expects(:find_all).with(**options).returns(tasks)
    tasks.expects(:to_a).returns(tasks)
  end

  def mock_tasks_from_project(options:)
    setup_config
    project_a.expects(:gid).returns(a_gid)
    client.expects(:tasks).returns(tasks)
    expect_tasks_found(options:)
  end

  def test_tasks_from_project_not_only_uncompleted
    projects = get_test_object do
      mock_tasks_from_project(options: task_options_with_completed)
    end

    assert_equal(tasks, projects.tasks_from_project(project_a,
                                                    only_uncompleted: false))
  end

  def test_tasks_from_project
    projects = get_test_object do
      mock_tasks_from_project(options: task_options(extra_fields: []))
    end

    assert_equal(tasks, projects.tasks_from_project(project_a))
  end

  def test_active_tasks
    projects = get_test_object do
      task_a.expects(:completed_at).returns(mock_now)
      task_b.expects(:completed_at).returns(nil)
    end

    assert_equal([task_b], projects.active_tasks([task_a, task_b]))
  end

  def setup_workspace_pulled
    @mocks[:workspaces].expects(:workspace_or_raise)
      .with('Workspace 1').returns(workspace_one)
    workspace_one.expects(:gid).returns(workspace_one_gid)
  end

  def setup_user_task_list_pulled
    client.expects(:user_task_lists).returns(user_task_lists)
    user_task_lists.expects(:get_user_task_list_for_user)
      .with(user_gid: 'me', workspace: workspace_one_gid)
      .returns(user_task_list)
    user_task_list.expects(:gid).returns(my_tasks_in_workspace_gid)
  end

  def mock_project_or_raise_unknown
    setup_config
    setup_workspace_pulled
    setup_projects_pulled
    setup_projects_queried(workspace_gid: workspace_one_gid)
  end

  def test_project_or_raise_unknown
    projects = get_test_object do
      mock_project_or_raise_unknown
    end
    assert_raises(RuntimeError) do
      projects.project_or_raise('Workspace 1', 'Does not exist')
    end
  end

  def test_project_by_gid
    projects = get_test_object do
      client.expects(:projects).returns(client_projects)
      client_projects.expects(:find_by_id).with(project_gid,
                                                options: { fields: %w[custom_fields name] }).returns(project)
    end

    assert_equal(project, projects.project_by_gid(project_gid))
  end

  def test_project_or_raise_my_tasks
    projects = get_test_object do
      mock_project_my_tasks
    end

    assert_equal(my_tasks_project, projects.project_or_raise('Workspace 1', :my_tasks))
  end

  def mock_project_my_tasks
    setup_config
    setup_workspace_pulled
    setup_projects_pulled
    setup_user_task_list_pulled
    projects
      .expects(:find_by_id).with(my_tasks_in_workspace_gid)
      .returns(my_tasks_project)
  end

  def test_project_my_tasks
    projects = get_test_object do
      mock_project_my_tasks
    end

    assert_equal(my_tasks_project, projects.project('Workspace 1', :my_tasks))
  end

  def test_project_to_h
    projects = get_test_object do
      project_hashes.expects(:project_to_h).with(project_a, project: :not_specified)
        .returns(project_a_hash)
    end

    assert_equal(project_a_hash, projects.project_to_h(project_a))
  end

  def mock_test_in_period
    project_timing.expects(:date_or_time_field_by_name)
      .with(project, field_name).returns(returned_date)
    timing.expects(:in_period?).with(returned_date, period)
      .returns(true)
  end

  def test_in_period
    projects = get_test_object do
      mock_test_in_period
    end

    assert(projects.in_period?(project, field_name, period))
  end

  def mock_project_ready
    project_timing.expects(:date_or_time_field_by_name)
      .with(project, :ready).returns(returned_date)
    timing.expects(:in_period?).with(returned_date, period)
      .returns(true)
  end

  def test_project_ready
    projects = get_test_object do
      mock_project_ready
    end

    assert(projects.project_ready?(project, period:))
  end

  let_mock :my_tasks_config

  def class_under_test
    Checkoff::Projects
  end
end
