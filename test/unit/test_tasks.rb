# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'checkoff/cli'

# Test the Checkoff::Tasks class
class TestTasks < BaseAsana
  extend Forwardable

  def_delegators :@mocks, :sections, :asana_task, :time_class, :date_class, :client, :workspaces,
                 :portfolios, :projects

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

  def expect_now_pulled
    time_class.expects(:now).returns(now).at_least_once
  end

  def expect_due_on_parsed(less_than_now:)
    date_class.expects(:parse).with(due_on_string).returns(due_on_date_obj).at_least(0)
    due_on_date_obj.expects(:to_time).returns(due_on_time_obj).at_least(0)
    due_on_time_obj.expects(:<).with(now).returns(less_than_now).at_least(0)
  end

  def expect_start_on_parsed(less_than_now:)
    date_class.expects(:parse).with(start_on_string).returns(start_on_date_obj)
    start_on_date_obj.expects(:to_time).returns(start_on_time_obj).at_least(1)
    start_on_time_obj.expects(:to_time).returns(start_on_time_obj).at_least(0)
    start_on_time_obj.expects(:<).with(now).returns(less_than_now)
  end

  def expect_start_at_parsed(less_than_now:)
    time_class.expects(:parse).with(start_at_string).returns(start_at_time_obj)
    start_at_time_obj.expects(:localtime).returns(start_at_time_obj)
    start_at_time_obj.expects(:to_time).returns(start_at_time_obj).at_least(0)
    start_at_time_obj.expects(:<).with(now).returns(less_than_now)
  end

  def mock_task_ready_false_due_in_future_on_date
    expect_dependency_gids_pulled(task, [])
    expect_now_pulled
    allow_task_due(due_on: due_on_string, due_at: nil)
    expect_due_on_parsed(less_than_now: false)
  end

  def test_task_ready_false_due_in_future_on_date
    tasks = get_test_object do
      mock_task_ready_false_due_in_future_on_date
    end

    refute(tasks.task_ready?(task))
  end

  def mock_task_ready_true_start_in_past
    expect_dependency_gids_pulled(task, [])
    allow_task_due(start_on: start_on_string, due_on: due_on_string, due_at: nil)
    expect_now_pulled
    expect_start_on_parsed(less_than_now: true)
    expect_due_on_parsed(less_than_now: false)
  end

  def test_task_ready_true_start_in_past
    tasks = get_test_object do
      mock_task_ready_true_start_in_past
    end

    assert(tasks.task_ready?(task))
  end

  def mock_task_ready_true_start_in_past_time
    expect_dependency_gids_pulled(task, [])
    allow_task_due(start_at: start_at_string, due_on: due_on_string, due_at: nil)
    expect_now_pulled
    expect_start_at_parsed(less_than_now: true)
    expect_due_on_parsed(less_than_now: false)
  end

  def test_task_ready_true_start_in_past_time
    tasks = get_test_object do
      mock_task_ready_true_start_in_past_time
    end

    assert(tasks.task_ready?(task))
  end

  def expect_due_at_parsed(less_than_now:)
    time_class.expects(:parse).with(due_at_string).returns(due_at_time_obj)
    due_at_time_obj.expects(:localtime).returns(due_at_time_obj)
    due_at_time_obj.expects(:to_time).returns(due_at_time_obj).at_least(0)
    time_class.expects(:now).returns(now)
    due_at_time_obj.expects(:<).with(now).returns(less_than_now)
  end

  def mock_task_ready_false_due_in_future_at_time
    expect_dependency_gids_pulled(task, [])
    allow_task_due(due_on: nil, due_at: due_at_string)
    expect_due_at_parsed(less_than_now: false)
  end

  def test_task_ready_false_due_in_future_at_time
    tasks = get_test_object do
      mock_task_ready_false_due_in_future_at_time
    end

    refute(tasks.task_ready?(task))
  end

  def expect_dependency_gids_pulled(task, dependency_gids)
    task.expects(:instance_variable_get).with(:@dependencies).returns(dependency_gids)
  end

  def test_task_ready_true_no_due_anything
    tasks = get_test_object do
      expect_dependency_gids_pulled(task, [])
      allow_task_due(due_on: nil, due_at: nil)
    end

    assert(tasks.task_ready?(task))
  end

  def expect_asana_tasks_client_pulled
    client.expects(:tasks).returns(asana_tasks_client)
  end

  def default_fields
    ['completed_at', 'due_at', 'due_on', 'memberships.project.gid', 'memberships.project.name',
     'memberships.section.name', 'name', 'start_at', 'start_on', 'tags']
  end

  def fields_including(extra_fields)
    (default_fields + extra_fields).sort.uniq
  end

  def expect_dependency_completion_pulled(dependency_gid, dependency_full_task,
                                          completed)
    expect_task_options_pulled
    expect_asana_tasks_client_pulled
    asana_tasks_client.expects(:find_by_id)
      .with(dependency_gid, options: { fields: fields_including(['dependencies']) })
      .returns(dependency_full_task)
    dependency_full_task.expects(:completed_at).returns(completed ? 'some time' : nil)
  end

  def mock_task_ready_false_dependency
    allow_task_due(due_on: nil, due_at: nil)
    expect_dependency_gids_pulled(task, [{ 'gid' => dependency_1_gid }])
    expect_dependency_completion_pulled(dependency_1_gid, dependency_1_full_task,
                                        false)
  end

  def test_task_ready_false_dependency
    tasks = get_test_object do
      mock_task_ready_false_dependency
    end

    refute(tasks.task_ready?(task))
  end

  def test_task_ready_false_dependency_cached
    tasks = get_test_object do
      allow_task_due(due_on: nil, due_at: nil)
      task.expects(:instance_variable_get).with(:@dependencies)
        .returns([{ 'gid' => dependency_1_gid }])
      expect_dependency_completion_pulled(dependency_1_gid, dependency_1_full_task,
                                          false)
    end

    refute(tasks.task_ready?(task))
  end

  def allow_task_due(start_on: nil, start_at: nil, due_on: nil, due_at: nil)
    allow_start_at_pulled(task, start_at)
    allow_start_on_pulled(task, start_on)
    allow_due_at_pulled(task, due_at)
    allow_due_on_pulled(task, due_on)
  end

  def allow_start_at_pulled(task, start_at)
    task.expects(:start_at).returns(start_at).at_least(0)
  end

  def allow_start_on_pulled(task, start_on)
    task.expects(:start_on).returns(start_on).at_least(0)
  end

  def allow_due_at_pulled(task, due_at)
    task.expects(:due_at).returns(due_at).at_least(0)
  end

  def allow_due_on_pulled(task, due_on)
    task.expects(:due_on).returns(due_on).at_least(0)
  end

  def test_url_of_task
    tasks = get_test_object do
      task.expects(:gid).returns('my_gid')
    end

    assert_equal('https://app.asana.com/0/0/my_gid/f', tasks.url_of_task(task))
  end

  def expect_task_created
    @mocks[:asana_task].expects(:create).with(client,
                                              assignee: default_assignee_gid,
                                              workspace: workspace_gid,
                                              name: task_name)
  end

  def mock_add_task
    @mocks[:config].expects(:fetch).with(:default_assignee_gid)
      .returns(default_assignee_gid)
    expect_task_created
  end

  def test_add_task
    tasks = get_test_object do
      mock_add_task
    end
    tasks.send(:add_task, task_name, workspace_gid:)
  end

  let_mock :workspace_name, :project_name, :section_name, :task_name, :task, :project

  def expect_tasks_from_project_pulled
    projects.expects(:tasks_from_project)
      .with(project,
            only_uncompleted: false,
            extra_fields: [])
      .returns([task])
    task.expects(:name).returns(task_name)
  end

  def expect_project_pulled
    projects.expects(:project_or_raise).with(workspace_name, project_name)
      .returns(project)
  end

  def expect_task_by_gid_pulled(extra_fields: [])
    task.expects(:gid).returns(task_gid)
    expect_task_options_pulled
    expect_asana_tasks_client_pulled
    asana_tasks_client.expects(:find_by_id).with(task_gid,
                                                 options: {
                                                   fields: fields_including(extra_fields),
                                                   completed_since: '9999-12-01',
                                                 })
      .returns(task)
  end

  def expect_tasks_from_section_pulled
    sections.expects(:tasks).with(workspace_name, project_name, section_name,
                                  only_uncompleted: false,
                                  extra_fields: []).returns([task])
    task.expects(:name).returns(task_name)
    expect_task_by_gid_pulled(extra_fields: ['dependencies'])
  end

  def projects
    @projects ||= Checkoff::Projects.new(client:,
                                         workspaces:)
  end

  def expect_task_options_pulled
    sections.expects(:projects).returns(projects).at_least(0)
  end

  def mock_task_with_section
    expect_tasks_from_section_pulled
    expect_task_options_pulled
  end

  def test_task_with_section
    tasks = get_test_object { mock_task_with_section }
    returned_task = tasks.task(workspace_name, project_name, task_name,
                               only_uncompleted: true, section_name:)

    assert_equal(task, returned_task)
  end

  def mock_task
    expect_project_pulled
    expect_tasks_from_project_pulled
    expect_task_by_gid_pulled(extra_fields: ['dependencies'])
  end

  def test_task
    tasks = get_test_object { mock_task }
    returned_task = tasks.task(workspace_name, project_name, task_name,
                               only_uncompleted: true)

    assert_equal(task, returned_task)
  end

  def test_in_portfolio_more_than_once
    tasks = get_test_object do
      portfolios.expects(:projects_in_portfolio).with('workspace_name', 'portfolio name')
        .returns([])
      task.expects(:memberships).returns([])
    end

    refute(tasks.in_portfolio_more_than_once?(task, 'portfolio name',
                                              workspace_name: 'workspace_name'))
  end

  def test_task_to_h_delegates
    tasks = get_test_object do
      Checkoff::Internal::TaskHashes.expects(:new).returns(task_hashes)
      task_hashes.expects(:task_to_h).with(task).returns(123)
    end

    assert_equal(123, tasks.task_to_h(task))
  end

  def expect_default_workspace_name_pulled
    workspaces.expects(:default_workspace).returns(default_workspace)
    default_workspace.expects(:name).returns('default workspace')
  end

  def mock_in_portfolio_named_false_no_projects_no_memberships
    expect_default_workspace_name_pulled
    portfolios.expects(:projects_in_portfolio).with('default workspace', 'portfolio name')
      .returns([])
    task.expects(:memberships).returns([])
  end

  def test_in_portfolio_named_false_no_projects_no_memberships
    tasks = get_test_object do
      mock_in_portfolio_named_false_no_projects_no_memberships
    end

    refute(tasks.in_portfolio_named?(task, 'portfolio name'))
  end

  def mock_in_portfolio_named_false_no_projects_but_memberships
    expect_default_workspace_name_pulled
    portfolios.expects(:projects_in_portfolio).with('default workspace', 'portfolio name')
      .returns([])
    memberships = [{ 'project' => { 'gid' => project_gid } }]
    task.expects(:memberships).returns(memberships)
  end

  def test_in_portfolio_named_false_no_projects_but_memberships
    tasks = get_test_object do
      mock_in_portfolio_named_false_no_projects_but_memberships
    end

    refute(tasks.in_portfolio_named?(task, 'portfolio name'))
  end

  def mock_in_portfolio_named_false_projects_wrong_memberships
    expect_default_workspace_name_pulled
    portfolios.expects(:projects_in_portfolio).with('default workspace', 'portfolio name')
      .returns([wrong_project])
    wrong_project.expects(:gid).returns(wrong_project_gid)
    memberships = [{ 'project' => { 'gid' => project_gid } }]
    task.expects(:memberships).returns(memberships)
  end

  def test_in_portfolio_named_false_projects_wrong_memberships
    tasks = get_test_object do
      mock_in_portfolio_named_false_projects_wrong_memberships
    end

    refute(tasks.in_portfolio_named?(task, 'portfolio name'))
  end

  def test_date_or_time_field_by_name
    tasks = get_test_object do
      task.expects(:due_at).returns(due_at_string).at_least(1)
      time_class.expects(:parse).with(due_at_string).returns(due_at_time_obj)
      due_at_time_obj.expects(:localtime).returns(due_at_time_obj)
    end

    assert_equal(due_at_time_obj, tasks.date_or_time_field_by_name(task, :due))
  end

  def test_h_to_task
    tasks = get_test_object
    task = tasks.h_to_task({ 'name' => 'foo' })

    assert_equal('foo', task.name)
  end

  def test_all_dependent_tasks_empty
    tasks = get_test_object do
      task.expects(:instance_variable_get).with(:@dependents).returns(nil)
    end

    assert_empty(tasks.all_dependent_tasks(task))
  end

  def test_all_dependent_tasks_one
    tasks = get_test_object do
      task.expects(:instance_variable_get).with(:@dependents).returns([{ 'gid' => dependent_1_gid }])

      expect_task_options_pulled
      expect_asana_tasks_client_pulled
      asana_tasks_client.expects(:find_by_id).with(dependent_1_gid,
                                                   options: { fields: fields_including(%w[dependencies dependents]),
                                                              completed_since: '9999-12-01' })
        .returns(dependent_1)
      dependent_1.expects(:instance_variable_get).with(:@dependents).returns([])
    end

    assert_equal([dependent_1], tasks.all_dependent_tasks(task))
  end

  def test_as_cache_key
    tasks = get_test_object

    assert_empty(tasks.as_cache_key)
  end

  def class_under_test
    Checkoff::Tasks
  end
end
