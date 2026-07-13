# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Projects class
class TestProjects < BaseAsana
  extend Forwardable

  def_delegators(:@mocks, :client, :project_hashes, :project_timing, :timing)

  # @return [void]
  def setup_config
    # @sg-ignore Unresolved call to @mocks
    @mocks[:config] = { personal_access_token: }
  end

  # @return [void]
  def setup_projects_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:projects).returns(projects).at_least(1)
  end

  let_mock :workspaces, :workspace_workspace, :some_other_workspace,
           :workspace_one, :workspace_one_gid, :my_workspace_gid, :n,
           :workspace_name, :all_workspaces, :my_tasks_project, :tasks,
           :task_a, :task_b, :user_task_lists, :user_task_list, :project_a_hash,
           :project, :project_gid, :client_projects, :field_name, :period,
           :returned_date

  # @return [void]
  def sample_projects
    # @sg-ignore Unresolved call to a_name
    # @sg-ignore Unresolved call to project_c
    # @sg-ignore Unresolved call to b_name
    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to project_b
    # @sg-ignore Unresolved call to c_name
    { project_a => a_name, project_b => b_name, project_c => c_name }
  end

  # @sg-ignore Unresolved call to my_workspace_gid
  # @return [void]
  # @param workspace_gid [Object]
  def setup_projects_queried(workspace_gid: my_workspace_gid)
    # @sg-ignore Unresolved call to projects
    projects
      .expects(:find_by_workspace).with(workspace: workspace_gid,
                                        per_page: 100,
                                        options: { fields: %w[custom_fields name] })
      .returns(sample_projects.keys)
    # @sg-ignore Unresolved call to each on void
    sample_projects.each do |project, name|
      project.expects(:name).returns(name).at_least(0)
    end
  end

  # @return [void]
  # @param options [Object]
  def expect_tasks_found(options:)
    # @sg-ignore Unresolved call to []=
    options[:project] = a_gid
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:find_all).with(**options).returns(tasks)
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:to_a).returns(tasks)
  end

  # @return [void]
  # @param options [Object]
  def mock_tasks_from_project(options:)
    setup_config
    # @sg-ignore Unresolved call to project_a
    project_a.expects(:gid).returns(a_gid)
    # @sg-ignore Unresolved call to client
    client.expects(:tasks).returns(tasks)
    expect_tasks_found(options:)
  end

  # @return [void]
  def test_tasks_from_project_not_only_uncompleted
    projects = get_test_object do
      mock_tasks_from_project(options: task_options_with_completed)
    end

    # @sg-ignore Unresolved call to tasks_from_project
    # @sg-ignore Unresolved call to tasks
    assert_equal(tasks, projects.tasks_from_project(project_a,
                                                    only_uncompleted: false))
  end

  # @return [void]
  def test_tasks_from_project
    projects = get_test_object do
      mock_tasks_from_project(options: task_options(extra_fields: []))
    end

    # @sg-ignore Unresolved call to tasks
    # @sg-ignore Unresolved call to tasks_from_project
    assert_equal(tasks, projects.tasks_from_project(project_a))
  end

  # @return [void]
  def test_active_tasks
    projects = get_test_object do
      # @sg-ignore Unresolved call to task_a
      task_a.expects(:completed_at).returns(mock_now)
      # @sg-ignore Unresolved call to task_b
      task_b.expects(:completed_at).returns(nil)
    end

    # @sg-ignore Unresolved call to task_b
    # @sg-ignore Unresolved call to active_tasks
    assert_equal([task_b], projects.active_tasks([task_a, task_b]))
  end

  # @return [void]
  def setup_workspace_pulled
    # @sg-ignore Unresolved call to @mocks
    @mocks[:workspaces].expects(:workspace_or_raise)
      .with('Workspace 1').returns(workspace_one)
    # @sg-ignore Unresolved call to workspace_one
    workspace_one.expects(:gid).returns(workspace_one_gid)
  end

  # @return [void]
  def setup_user_task_list_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:user_task_lists).returns(user_task_lists)
    # @sg-ignore Unresolved call to user_task_lists
    user_task_lists.expects(:get_user_task_list_for_user)
      .with(user_gid: 'me', workspace: workspace_one_gid)
      .returns(user_task_list)
    # @sg-ignore Unresolved call to user_task_list
    user_task_list.expects(:gid).returns(my_tasks_in_workspace_gid)
  end

  # @return [void]
  def mock_project_or_raise_unknown
    setup_config
    setup_workspace_pulled
    setup_projects_pulled
    # @sg-ignore Unresolved call to workspace_one_gid
    setup_projects_queried(workspace_gid: workspace_one_gid)
  end

  # @return [void]
  def test_project_or_raise_unknown
    projects = get_test_object do
      mock_project_or_raise_unknown
    end
    assert_raises(RuntimeError) do
      # @sg-ignore Unresolved call to project_or_raise
      projects.project_or_raise('Workspace 1', 'Does not exist')
    end
  end

  # @return [void]
  def test_project_by_gid
    projects = get_test_object do
      # @sg-ignore Unresolved call to client
      client.expects(:projects).returns(client_projects)
      # @sg-ignore Unresolved call to client_projects
      client_projects.expects(:find_by_id).with(project_gid,
                                                options: { fields: %w[custom_fields name] }).returns(project)
    end

    # @sg-ignore Unresolved call to project_by_gid
    # @sg-ignore Unresolved call to project
    assert_equal(project, projects.project_by_gid(project_gid))
  end

  # @return [void]
  def test_project_or_raise_my_tasks
    projects = get_test_object do
      mock_project_my_tasks
    end

    # @sg-ignore Unresolved call to my_tasks_project
    # @sg-ignore Unresolved call to project_or_raise
    assert_equal(my_tasks_project, projects.project_or_raise('Workspace 1', :my_tasks))
  end

  # @return [void]
  def mock_project_my_tasks
    setup_config
    setup_workspace_pulled
    setup_projects_pulled
    setup_user_task_list_pulled
    # @sg-ignore Unresolved call to projects
    projects
      .expects(:find_by_id).with(my_tasks_in_workspace_gid)
      .returns(my_tasks_project)
  end

  # @return [void]
  def test_project_my_tasks
    projects = get_test_object do
      mock_project_my_tasks
    end

    # @sg-ignore Unresolved call to project
    # @sg-ignore Unresolved call to my_tasks_project
    assert_equal(my_tasks_project, projects.project('Workspace 1', :my_tasks))
  end

  # @return [void]
  def test_project_to_h
    projects = get_test_object do
      # @sg-ignore Unresolved call to project_hashes
      project_hashes.expects(:project_to_h).with(project_a, project: :not_specified)
        .returns(project_a_hash)
    end

    # @sg-ignore Unresolved call to project_a_hash
    # @sg-ignore Unresolved call to project_to_h
    assert_equal(project_a_hash, projects.project_to_h(project_a))
  end

  # @return [void]
  def mock_test_in_period
    # @sg-ignore Unresolved call to project_timing
    project_timing.expects(:date_or_time_field_by_name)
      .with(project, field_name).returns(returned_date)
    # @sg-ignore Unresolved call to timing
    timing.expects(:in_period?).with(returned_date, period)
      .returns(true)
  end

  # @return [void]
  def test_in_period
    projects = get_test_object do
      mock_test_in_period
    end

    # @sg-ignore Unresolved call to in_period?
    assert(projects.in_period?(project, field_name, period))
  end

  # @return [void]
  def mock_project_ready
    # @sg-ignore Unresolved call to project_timing
    project_timing.expects(:date_or_time_field_by_name)
      .with(project, :ready).returns(returned_date)
    # @sg-ignore Unresolved call to timing
    timing.expects(:in_period?).with(returned_date, period)
      .returns(true)
  end

  # @return [void]
  def test_project_ready
    projects = get_test_object do
      mock_project_ready
    end

    # @sg-ignore Unresolved call to project_ready?
    assert(projects.project_ready?(project, period:))
  end

  let_mock :my_tasks_config

  # @return [void]
  def class_under_test
    Checkoff::Projects
  end
end
