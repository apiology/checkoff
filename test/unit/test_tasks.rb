# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'checkoff/cli'

# Test the Checkoff::Tasks class
class TestTasks < BaseAsana
  extend Forwardable

  def_delegators :@mocks, :sections, :asana_task, :time_class, :date_class, :client, :workspaces,
                 :portfolios

  let_mock :mock_tasks, :modified_mock_tasks, :tasks_by_section,
           :unflattened_modified_mock_tasks, :task_hashes, :project_gid, :wrong_project,
           :wrong_project_gid, :asana_tasks_client, :task_gid

  let_mock :default_workspace, :workspace_gid, :task_name, :default_assignee_gid

  let_mock :task,
           :start_on_string, :start_on_date_obj,
           :start_on_time_obj,
           :start_at_string, :start_at_time_obj,
           :due_at_string, :due_at_time_obj,
           :due_on_string, :due_on_date_obj,
           :due_on_time_obj,
           :asana_entity_project,
           :dependency_1, :dependency_1_gid,
           :dependency_1_full_task, :now,
           :dependent_1, :dependent_1_gid

  # @return [void]
  def expect_now_pulled
    # @sg-ignore Unresolved call to time_class
    time_class.expects(:now).returns(now).at_least_once
  end

  # @return [void]
  # @param less_than_now [Object]
  def expect_due_on_parsed(less_than_now:)
    # @sg-ignore Unresolved call to date_class
    date_class.expects(:parse).with(due_on_string).returns(due_on_date_obj).at_least(0)
    # @sg-ignore Unresolved call to due_on_date_obj
    due_on_date_obj.expects(:to_time).returns(due_on_time_obj).at_least(0)
    # @sg-ignore Unresolved call to due_on_time_obj
    due_on_time_obj.expects(:<).with(now).returns(less_than_now).at_least(0)
  end

  # @return [void]
  # @param less_than_now [Object]
  def expect_start_on_parsed(less_than_now:)
    # @sg-ignore Unresolved call to date_class
    date_class.expects(:parse).with(start_on_string).returns(start_on_date_obj)
    # @sg-ignore Unresolved call to start_on_date_obj
    start_on_date_obj.expects(:to_time).returns(start_on_time_obj).at_least(1)
    # @sg-ignore Unresolved call to start_on_time_obj
    start_on_time_obj.expects(:to_time).returns(start_on_time_obj).at_least(0)
    # @sg-ignore Unresolved call to start_on_time_obj
    start_on_time_obj.expects(:<).with(now).returns(less_than_now)
  end

  # @return [void]
  # @param less_than_now [Object]
  def expect_start_at_parsed(less_than_now:)
    # @sg-ignore Unresolved call to time_class
    time_class.expects(:parse).with(start_at_string).returns(start_at_time_obj)
    # @sg-ignore Unresolved call to start_at_time_obj
    start_at_time_obj.expects(:localtime).returns(start_at_time_obj)
    # @sg-ignore Unresolved call to start_at_time_obj
    start_at_time_obj.expects(:to_time).returns(start_at_time_obj).at_least(0)
    # @sg-ignore Unresolved call to start_at_time_obj
    start_at_time_obj.expects(:<).with(now).returns(less_than_now)
  end

  # @return [void]
  def mock_task_ready_false_due_in_future_on_date
    # @sg-ignore Unresolved call to task
    expect_dependency_gids_pulled(task, [])
    expect_now_pulled
    # @sg-ignore Unresolved call to due_on_string
    allow_task_due(due_on: due_on_string, due_at: nil)
    expect_due_on_parsed(less_than_now: false)
  end

  # @return [void]
  def test_task_ready_false_due_in_future_on_date
    tasks = get_test_object do
      mock_task_ready_false_due_in_future_on_date
    end

    # @sg-ignore Unresolved call to task_ready?
    refute(tasks.task_ready?(task))
  end

  # @return [void]
  def mock_task_ready_true_start_in_past
    # @sg-ignore Unresolved call to task
    expect_dependency_gids_pulled(task, [])
    # @sg-ignore Unresolved call to start_on_string
    # @sg-ignore Unresolved call to due_on_string
    allow_task_due(start_on: start_on_string, due_on: due_on_string, due_at: nil)
    expect_now_pulled
    expect_start_on_parsed(less_than_now: true)
    expect_due_on_parsed(less_than_now: false)
  end

  # @return [void]
  def test_task_ready_true_start_in_past
    tasks = get_test_object do
      mock_task_ready_true_start_in_past
    end

    # @sg-ignore Unresolved call to task_ready?
    assert(tasks.task_ready?(task))
  end

  # @return [void]
  def mock_task_ready_true_start_in_past_time
    # @sg-ignore Unresolved call to task
    expect_dependency_gids_pulled(task, [])
    # @sg-ignore Unresolved call to start_at_string
    # @sg-ignore Unresolved call to due_on_string
    allow_task_due(start_at: start_at_string, due_on: due_on_string, due_at: nil)
    expect_now_pulled
    expect_start_at_parsed(less_than_now: true)
    expect_due_on_parsed(less_than_now: false)
  end

  # @return [void]
  def test_task_ready_true_start_in_past_time
    tasks = get_test_object do
      mock_task_ready_true_start_in_past_time
    end

    # @sg-ignore Unresolved call to task_ready?
    assert(tasks.task_ready?(task))
  end

  # @return [void]
  # @param less_than_now [Object]
  def expect_due_at_parsed(less_than_now:)
    # @sg-ignore Unresolved call to time_class
    time_class.expects(:parse).with(due_at_string).returns(due_at_time_obj)
    # @sg-ignore Unresolved call to due_at_time_obj
    due_at_time_obj.expects(:localtime).returns(due_at_time_obj)
    # @sg-ignore Unresolved call to due_at_time_obj
    due_at_time_obj.expects(:to_time).returns(due_at_time_obj).at_least(0)
    # @sg-ignore Unresolved call to time_class
    time_class.expects(:now).returns(now)
    # @sg-ignore Unresolved call to due_at_time_obj
    due_at_time_obj.expects(:<).with(now).returns(less_than_now)
  end

  # @return [void]
  def mock_task_ready_false_due_in_future_at_time
    # @sg-ignore Unresolved call to task
    expect_dependency_gids_pulled(task, [])
    # @sg-ignore Unresolved call to due_at_string
    allow_task_due(due_on: nil, due_at: due_at_string)
    expect_due_at_parsed(less_than_now: false)
  end

  # @return [void]
  def test_task_ready_false_due_in_future_at_time
    tasks = get_test_object do
      mock_task_ready_false_due_in_future_at_time
    end

    # @sg-ignore Unresolved call to task_ready?
    refute(tasks.task_ready?(task))
  end

  # @return [void]
  # @param dependency_gids [Object]
  # @param task [Object]
  def expect_dependency_gids_pulled(task, dependency_gids)
    task.expects(:instance_variable_get).with(:@dependencies).returns(dependency_gids)
  end

  # @return [void]
  def test_task_ready_true_no_due_anything
    tasks = get_test_object do
      # @sg-ignore Unresolved call to task
      expect_dependency_gids_pulled(task, [])
      allow_task_due(due_on: nil, due_at: nil)
    end

    # @sg-ignore Unresolved call to task_ready?
    assert(tasks.task_ready?(task))
  end

  # @return [void]
  def expect_asana_tasks_client_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:tasks).returns(asana_tasks_client)
  end

  # @return [void]
  def default_fields
    ['completed_at', 'due_at', 'due_on', 'memberships.project.gid', 'memberships.project.name',
     'memberships.section.name', 'name', 'start_at', 'start_on', 'tags']
  end

  # @return [void]
  # @param extra_fields [Object]
  def fields_including(extra_fields)
    # @sg-ignore Unresolved call to + on void
    (default_fields + extra_fields).sort.uniq
  end

  # @return [void]
  # @param dependency_full_task [Object]
  # @param dependency_gid [Object]
  # @param completed [Object]
  def expect_dependency_completion_pulled(dependency_gid, dependency_full_task,
                                          completed)
    expect_task_options_pulled
    expect_asana_tasks_client_pulled
    # @sg-ignore Unresolved call to asana_tasks_client
    asana_tasks_client.expects(:find_by_id)
      .with(dependency_gid, options: { fields: fields_including(['dependencies']) })
      .returns(dependency_full_task)
    dependency_full_task.expects(:completed_at).returns(completed ? 'some time' : nil)
  end

  # @return [void]
  def mock_task_ready_false_dependency
    allow_task_due(due_on: nil, due_at: nil)
    # @sg-ignore Unresolved call to task
    # @sg-ignore Unresolved call to dependency_1_gid
    expect_dependency_gids_pulled(task, [{ 'gid' => dependency_1_gid }])
    # @sg-ignore Unresolved call to dependency_1_gid
    # @sg-ignore Unresolved call to dependency_1_full_task
    expect_dependency_completion_pulled(dependency_1_gid, dependency_1_full_task,
                                        false)
  end

  # @return [void]
  def test_task_ready_false_dependency
    tasks = get_test_object do
      mock_task_ready_false_dependency
    end

    # @sg-ignore Unresolved call to task_ready?
    refute(tasks.task_ready?(task))
  end

  # @return [void]
  def test_task_ready_false_dependency_cached
    tasks = get_test_object do
      allow_task_due(due_on: nil, due_at: nil)
      # @sg-ignore Unresolved call to task
      task.expects(:instance_variable_get).with(:@dependencies)
        .returns([{ 'gid' => dependency_1_gid }])
      # @sg-ignore Unresolved call to dependency_1_full_task
      # @sg-ignore Unresolved call to dependency_1_gid
      expect_dependency_completion_pulled(dependency_1_gid, dependency_1_full_task,
                                          false)
    end

    # @sg-ignore Unresolved call to task_ready?
    refute(tasks.task_ready?(task))
  end

  # @return [void]
  # @param dependency_gid [Object]
  def expect_dependency_missing(dependency_gid)
    expect_task_options_pulled
    expect_asana_tasks_client_pulled
    # @sg-ignore Unresolved call to asana_tasks_client
    asana_tasks_client.expects(:find_by_id)
      .with(dependency_gid, options: { fields: fields_including(['dependencies']) })
      .returns(nil)
  end

  # @return [void]
  def mock_task_ready_false_dependency_missing
    allow_task_due(due_on: nil, due_at: nil)
    # @sg-ignore Unresolved call to dependency_1_gid
    # @sg-ignore Unresolved call to task
    expect_dependency_gids_pulled(task, [{ 'gid' => dependency_1_gid }])
    # @sg-ignore Unresolved call to dependency_1_gid
    expect_dependency_missing(dependency_1_gid)
  end

  # @return [void]
  def test_task_ready_false_dependency_missing
    tasks = get_test_object do
      mock_task_ready_false_dependency_missing
    end

    # @sg-ignore Unresolved call to task_ready?
    refute(tasks.task_ready?(task))
  end

  # @return [void]
  # @param due_at [Object]
  # @param due_on [Object]
  # @param start_at [Object]
  # @param start_on [Object]
  def allow_task_due(start_on: nil, start_at: nil, due_on: nil, due_at: nil)
    # @sg-ignore Unresolved call to task
    allow_start_at_pulled(task, start_at)
    # @sg-ignore Unresolved call to task
    allow_start_on_pulled(task, start_on)
    # @sg-ignore Unresolved call to task
    allow_due_at_pulled(task, due_at)
    # @sg-ignore Unresolved call to task
    allow_due_on_pulled(task, due_on)
  end

  # @return [void]
  # @param start_at [Object]
  # @param task [Object]
  def allow_start_at_pulled(task, start_at)
    task.expects(:start_at).returns(start_at).at_least(0)
  end

  # @param start_on [Object]
  # @return [void]
  # @param task [Object]
  def allow_start_on_pulled(task, start_on)
    task.expects(:start_on).returns(start_on).at_least(0)
  end

  # @return [void]
  # @param due_at [Object]
  # @param task [Object]
  def allow_due_at_pulled(task, due_at)
    task.expects(:due_at).returns(due_at).at_least(0)
  end

  # @param due_on [Object]
  # @param task [Object]
  # @return [void]
  def allow_due_on_pulled(task, due_on)
    task.expects(:due_on).returns(due_on).at_least(0)
  end

  # @return [void]
  def test_url_of_task
    tasks = get_test_object do
      # @sg-ignore Unresolved call to task
      task.expects(:gid).returns('my_gid')
    end

    # @sg-ignore Unresolved call to url_of_task
    assert_equal('https://app.asana.com/0/0/my_gid/f', tasks.url_of_task(task))
  end

  # @return [void]
  def expect_task_created
    # @sg-ignore Unresolved call to @mocks
    @mocks[:asana_task].expects(:create).with(client,
                                              assignee: default_assignee_gid,
                                              workspace: workspace_gid,
                                              name: task_name)
  end

  # @return [void]
  def mock_add_task
    # @sg-ignore Unresolved call to @mocks
    @mocks[:config].expects(:fetch).with(:default_assignee_gid)
      .returns(default_assignee_gid)
    expect_task_created
  end

  # @return [void]
  def test_add_task
    tasks = get_test_object do
      mock_add_task
    end
    # @sg-ignore Unresolved call to task_name
    # @sg-ignore Unresolved call to workspace_gid
    tasks.send(:add_task, task_name, workspace_gid:)
  end

  let_mock :workspace_name, :project_name, :section_name, :task_name, :task, :project

  # @return [void]
  def expect_tasks_from_project_pulled
    projects.expects(:tasks_from_project)
      # @sg-ignore Unresolved call to project
      .with(project,
            only_uncompleted: false,
            extra_fields: [])
      # @sg-ignore Unresolved call to task
      .returns([task])
    # @sg-ignore Unresolved call to task
    task.expects(:name).returns(task_name)
  end

  # @return [void]
  def expect_project_pulled
    # @sg-ignore Unresolved call to project_name
    # @sg-ignore Unresolved call to workspace_name
    projects.expects(:project_or_raise).with(workspace_name, project_name)
      # @sg-ignore Unresolved call to project
      .returns(project)
  end

  # @param extra_fields [Object]
  # @return [void]
  def expect_task_by_gid_pulled(extra_fields: [])
    # @sg-ignore Unresolved call to task
    task.expects(:gid).returns(task_gid)
    expect_task_options_pulled
    expect_asana_tasks_client_pulled
    # @sg-ignore Unresolved call to asana_tasks_client
    asana_tasks_client.expects(:find_by_id).with(task_gid,
                                                 options: {
                                                   fields: fields_including(extra_fields),
                                                   completed_since: '9999-12-01',
                                                 })
      .returns(task)
  end

  # @return [void]
  def expect_tasks_from_section_pulled
    # @sg-ignore Unresolved call to sections
    sections.expects(:tasks).with(workspace_name, project_name, section_name,
                                  only_uncompleted: false,
                                  extra_fields: []).returns([task])
    # @sg-ignore Unresolved call to task
    task.expects(:name).returns(task_name)
    expect_task_by_gid_pulled(extra_fields: ['dependencies'])
  end

  # @return [void]
  def projects
    # @sg-ignore Unresolved call to client
    @projects ||= Checkoff::Projects.new(client:,
                                         # @sg-ignore Unresolved call to workspaces
                                         workspaces:)
  end

  # @return [void]
  def expect_task_options_pulled
    # @sg-ignore Unresolved call to sections
    sections.expects(:projects).returns(projects).at_least(0)
  end

  # @return [void]
  def mock_task_with_section
    expect_tasks_from_section_pulled
    expect_task_options_pulled
  end

  # @return [void]
  def test_task_with_section
    tasks = get_test_object { mock_task_with_section }
    # @sg-ignore Unresolved call to task
    returned_task = tasks.task(workspace_name, project_name, task_name,
                               only_uncompleted: true, section_name:)

    # @sg-ignore Unresolved call to task
    assert_equal(task, returned_task)
  end

  # @return [void]
  def mock_task
    expect_project_pulled
    expect_tasks_from_project_pulled
    expect_task_by_gid_pulled(extra_fields: ['dependencies'])
  end

  # @return [void]
  def test_task
    tasks = get_test_object { mock_task }
    # @sg-ignore Unresolved call to task
    returned_task = tasks.task(workspace_name, project_name, task_name,
                               only_uncompleted: true)

    # @sg-ignore Unresolved call to task
    assert_equal(task, returned_task)
  end

  # @return [void]
  def test_in_portfolio_more_than_once
    tasks = get_test_object do
      # @sg-ignore Unresolved call to portfolios
      portfolios.expects(:projects_in_portfolio).with('workspace_name', 'portfolio name')
        .returns([])
      # @sg-ignore Unresolved call to task
      task.expects(:memberships).returns([])
    end

    # @sg-ignore Unresolved call to in_portfolio_more_than_once?
    refute(tasks.in_portfolio_more_than_once?(task, 'portfolio name',
                                              workspace_name: 'workspace_name'))
  end

  # @return [void]
  def test_in_portfolio_more_than_once_true
    tasks = get_test_object do
      portfolio_project = mock('portfolio_project')
      # @sg-ignore Unresolved call to project_gid
      portfolio_project.expects(:gid).returns(project_gid)
      # @sg-ignore Unresolved call to portfolios
      portfolios.expects(:projects_in_portfolio).with('workspace_name', 'portfolio name')
        .returns([portfolio_project])
      memberships = [
        # @sg-ignore Unresolved call to project_gid
        { 'project' => { 'gid' => project_gid } },
        # @sg-ignore Unresolved call to project_gid
        { 'project' => { 'gid' => project_gid } },
      ]
      # @sg-ignore Unresolved call to task
      task.expects(:memberships).returns(memberships)
    end

    # @sg-ignore Unresolved call to in_portfolio_more_than_once?
    assert(tasks.in_portfolio_more_than_once?(task, 'portfolio name',
                                              workspace_name: 'workspace_name'))
  end

  # @return [void]
  def test_gid_for_task
    tasks = get_test_object do
      # @sg-ignore Unresolved call to client
      projects_instance = Checkoff::Projects.new(client:)
      # @sg-ignore Unresolved call to sections
      sections.expects(:projects).returns(projects_instance).at_least_once
      # @sg-ignore Unresolved call to workspace_name
      # @sg-ignore Unresolved call to project_name
      # @sg-ignore Unresolved call to project
      projects_instance.expects(:project_or_raise).with(workspace_name, project_name).returns(project)
      projects_instance.expects(:tasks_from_project)
        # @sg-ignore Unresolved call to project
        .with(project, only_uncompleted: false, extra_fields: [])
        # @sg-ignore Unresolved call to task
        .returns([task])
      # @sg-ignore Unresolved call to task
      task.expects(:name).returns(task_name)
      # @sg-ignore Unresolved call to task
      task.expects(:gid).returns(task_gid)
    end

    # @sg-ignore Unresolved call to task_gid
    assert_equal(task_gid,
                 # @sg-ignore Unresolved call to gid_for_task
                 tasks.gid_for_task(workspace_name, project_name, :unspecified, task_name))
  end

  # @return [void]
  def test_gid_for_task_not_found
    tasks = get_test_object do
      # @sg-ignore Unresolved call to client
      projects_instance = Checkoff::Projects.new(client:)
      # @sg-ignore Unresolved call to sections
      sections.expects(:projects).returns(projects_instance).at_least_once
      # @sg-ignore Unresolved call to workspace_name
      # @sg-ignore Unresolved call to project_name
      # @sg-ignore Unresolved call to project
      projects_instance.expects(:project_or_raise).with(workspace_name, project_name).returns(project)
      projects_instance.expects(:tasks_from_project)
        # @sg-ignore Unresolved call to project
        .with(project, only_uncompleted: false, extra_fields: [])
        .returns([])
    end

    # @sg-ignore Unresolved call to gid_for_task
    assert_nil(tasks.gid_for_task(workspace_name, project_name, :unspecified, task_name))
  end

  # @return [void]
  def test_task_to_h_delegates
    tasks = get_test_object do
      # @sg-ignore Unresolved call to task_hashes
      Checkoff::Internal::TaskHashes.expects(:new).returns(task_hashes)
      # @sg-ignore Unresolved call to task_hashes
      task_hashes.expects(:task_to_h).with(task).returns(123)
    end

    # @sg-ignore Unresolved call to task_to_h
    assert_equal(123, tasks.task_to_h(task))
  end

  # @return [void]
  def expect_default_workspace_name_pulled
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:default_workspace).returns(default_workspace)
    # @sg-ignore Unresolved call to default_workspace
    default_workspace.expects(:name).returns('default workspace')
  end

  # @return [void]
  def mock_in_portfolio_named_false_no_projects_no_memberships
    expect_default_workspace_name_pulled
    # @sg-ignore Unresolved call to portfolios
    portfolios.expects(:projects_in_portfolio).with('default workspace', 'portfolio name')
      .returns([])
    # @sg-ignore Unresolved call to task
    task.expects(:memberships).returns([])
  end

  # @return [void]
  def test_in_portfolio_named_false_no_projects_no_memberships
    tasks = get_test_object do
      mock_in_portfolio_named_false_no_projects_no_memberships
    end

    # @sg-ignore Unresolved call to in_portfolio_named?
    refute(tasks.in_portfolio_named?(task, 'portfolio name'))
  end

  # @return [void]
  def mock_in_portfolio_named_false_no_projects_but_memberships
    expect_default_workspace_name_pulled
    # @sg-ignore Unresolved call to portfolios
    portfolios.expects(:projects_in_portfolio).with('default workspace', 'portfolio name')
      .returns([])
    # @sg-ignore Unresolved call to project_gid
    memberships = [{ 'project' => { 'gid' => project_gid } }]
    # @sg-ignore Unresolved call to task
    task.expects(:memberships).returns(memberships)
  end

  # @return [void]
  def test_in_portfolio_named_false_no_projects_but_memberships
    tasks = get_test_object do
      mock_in_portfolio_named_false_no_projects_but_memberships
    end

    # @sg-ignore Unresolved call to in_portfolio_named?
    refute(tasks.in_portfolio_named?(task, 'portfolio name'))
  end

  # @return [void]
  def mock_in_portfolio_named_false_projects_wrong_memberships
    expect_default_workspace_name_pulled
    # @sg-ignore Unresolved call to portfolios
    portfolios.expects(:projects_in_portfolio).with('default workspace', 'portfolio name')
      .returns([wrong_project])
    # @sg-ignore Unresolved call to wrong_project
    wrong_project.expects(:gid).returns(wrong_project_gid)
    # @sg-ignore Unresolved call to project_gid
    memberships = [{ 'project' => { 'gid' => project_gid } }]
    # @sg-ignore Unresolved call to task
    task.expects(:memberships).returns(memberships)
  end

  # @return [void]
  def test_in_portfolio_named_false_projects_wrong_memberships
    tasks = get_test_object do
      mock_in_portfolio_named_false_projects_wrong_memberships
    end

    # @sg-ignore Unresolved call to in_portfolio_named?
    refute(tasks.in_portfolio_named?(task, 'portfolio name'))
  end

  # @return [void]
  def test_date_or_time_field_by_name
    tasks = get_test_object do
      # @sg-ignore Unresolved call to task
      task.expects(:due_at).returns(due_at_string).at_least(1)
      # @sg-ignore Unresolved call to time_class
      time_class.expects(:parse).with(due_at_string).returns(due_at_time_obj)
      # @sg-ignore Unresolved call to due_at_time_obj
      due_at_time_obj.expects(:localtime).returns(due_at_time_obj)
    end

    # @sg-ignore Unresolved call to due_at_time_obj
    # @sg-ignore Unresolved call to date_or_time_field_by_name
    assert_equal(due_at_time_obj, tasks.date_or_time_field_by_name(task, :due))
  end

  # @return [void]
  def test_h_to_task
    tasks = get_test_object
    # @sg-ignore Unresolved call to h_to_task
    task = tasks.h_to_task({ 'name' => 'foo' })

    # @sg-ignore Unresolved call to name
    assert_equal('foo', task.name)
  end

  # @return [void]
  def test_all_dependent_tasks_empty
    tasks = get_test_object do
      # @sg-ignore Unresolved call to task
      task.expects(:instance_variable_get).with(:@dependents).returns(nil)
    end

    # @sg-ignore Unresolved call to all_dependent_tasks
    assert_empty(tasks.all_dependent_tasks(task))
  end

  # @return [void]
  def test_all_dependent_tasks_one
    tasks = get_test_object do
      # @sg-ignore Unresolved call to task
      task.expects(:instance_variable_get).with(:@dependents).returns([{ 'gid' => dependent_1_gid }])

      expect_task_options_pulled
      expect_asana_tasks_client_pulled
      # @sg-ignore Unresolved call to asana_tasks_client
      asana_tasks_client.expects(:find_by_id).with(dependent_1_gid,
                                                   options: { fields: fields_including(%w[dependencies dependents]),
                                                              completed_since: '9999-12-01' })
        .returns(dependent_1)
      # @sg-ignore Unresolved call to dependent_1
      dependent_1.expects(:instance_variable_get).with(:@dependents).returns([])
    end

    # @sg-ignore Unresolved call to dependent_1
    # @sg-ignore Unresolved call to all_dependent_tasks
    assert_equal([dependent_1], tasks.all_dependent_tasks(task))
  end

  # @return [void]
  def test_as_cache_key
    tasks = get_test_object

    # @sg-ignore Unresolved call to as_cache_key
    assert_empty(tasks.as_cache_key)
  end

  # @return [void]
  def class_under_test
    Checkoff::Tasks
  end
end
