# frozen_string_literal: true

require_relative 'base_asana'
require 'checkoff/cli'

# Test the Checkoff::Tasks class
class TestTasks < BaseAsana
  extend Forwardable

  def_delegators :@mocks, :sections, :asana_task, :time_class

  let_mock :mock_tasks, :modified_mock_tasks, :tasks_by_section,
           :unflattened_modified_mock_tasks

  let_mock :workspace_gid, :task_name, :default_assignee_gid

  let_mock :task,
           :due_at_string, :due_at_obj,
           :due_on_string, :due_on_obj,
           :asana_entity_project,
           :dependency_1, :dependency_1_gid, :client,
           :dependency_1_full_task, :now

  def expect_due_on_parsed(less_than_now:)
    time_class.expects(:parse).with(due_on_string).returns(due_on_obj)
    time_class.expects(:now).returns(now)
    due_on_obj.expects(:<).with(now).returns(less_than_now)
  end

  def mock_task_ready_false_due_in_future_on_date
    allow_client_pulled
    expect_dependencies_pulled(task, [])
    allow_task_due(due_on: due_on_string, due_at: nil)
    expect_due_on_parsed(less_than_now: false)
  end

  def test_task_ready_false_due_in_future_on_date
    tasks = get_test_object do
      mock_task_ready_false_due_in_future_on_date
    end
    refute(tasks.task_ready?(task))
  end

  def expect_due_at_parsed(less_than_now:)
    time_class.expects(:parse).with(due_at_string).returns(due_at_obj)
    time_class.expects(:now).returns(now)
    due_at_obj.expects(:<).with(now).returns(less_than_now)
  end

  def mock_task_ready_false_due_in_future_at_time
    allow_client_pulled
    expect_dependencies_pulled(task, [])
    allow_task_due(due_on: nil, due_at: due_at_string)
    expect_due_at_parsed(less_than_now: false)
  end

  def test_task_ready_false_due_in_future_at_time
    tasks = get_test_object do
      mock_task_ready_false_due_in_future_at_time
    end
    refute(tasks.task_ready?(task))
  end

  def expect_dependencies_pulled(task, dependencies)
    task.expects(:dependencies).returns(dependencies)
  end

  def test_task_ready_true_no_due_anything
    tasks = get_test_object do
      expect_dependencies_pulled(task, [])
      allow_task_due(due_on: nil, due_at: nil)
    end
    assert(tasks.task_ready?(task))
  end

  def expect_dependency_completion_pulled(dependency, dependency_gid, dependency_full_task,
                                          completed)
    dependency.expects(:gid).with.returns(dependency_1_gid)
    asana_task.expects(:find_by_id).with(client,
                                         dependency_gid,
                                         options: { fields: ['completed'] })
      .returns(dependency_full_task)
    dependency_full_task.expects(:completed).returns(completed)
  end

  def allow_client_pulled
    sections.expects(:client).returns(client).at_least(0)
  end

  def mock_task_ready_false_dependency
    allow_client_pulled
    allow_task_due(due_on: nil, due_at: nil)
    expect_dependencies_pulled(task, [dependency_1])
    expect_dependency_completion_pulled(dependency_1, dependency_1_gid, dependency_1_full_task,
                                        false)
  end

  def test_task_ready_false_dependency
    tasks = get_test_object do
      mock_task_ready_false_dependency
    end
    refute(tasks.task_ready?(task))
  end

  def allow_task_due(due_on: nil, due_at: nil)
    allow_due_at_pulled(task, due_at)
    allow_due_on_pulled(task, due_on)
  end

  def allow_due_at_pulled(task, due_at)
    task.expects(:due_at).returns(due_at).at_least(0)
  end

  def allow_due_on_pulled(task, due_on)
    task.expects(:due_on).returns(due_on).at_least(0)
  end

  def mock_due_time_nil
    expect_init_called
    allow_due_at_pulled(task, nil)
    allow_due_on_pulled(task, nil)
  end

  def mock_due_time_due_at_set
    expect_init_called
    task.expects(:due_at).returns(due_at_string).at_least(1)
    @mocks[:time_class].expects(:parse).with(due_at_string).returns(due_at_obj)
  end

  def mock_due_time_due_on_set
    expect_init_called
    task.expects(:due_at).returns(nil).at_least(1)
    task.expects(:due_on).returns(due_on_string).at_least(1)
    @mocks[:time_class].expects(:parse).with(due_on_string).returns(due_on_obj)
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
    @mocks[:sections].expects(:client).returns(client)
    expect_task_created
  end

  def test_add_task
    tasks = get_test_object do
      mock_add_task
    end
    tasks.send(:add_task, task_name, workspace_gid: workspace_gid)
  end

  let_mock :workspace_name, :project_name, :section_name, :task_name,
           :only_uncompleted, :task, :projects, :project

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

  def expect_tasks_from_section_pulled
    sections.expects(:tasks).with(workspace_name, project_name, section_name,
                                  only_uncompleted: only_uncompleted).returns([task])
    task.expects(:name).returns(task_name)
  end

  def mock_task_with_section
    expect_projects_pulled
    expect_project_pulled
    expect_tasks_from_section_pulled
  end

  def test_task_with_section
    tasks = get_test_object { mock_task_with_section }
    returned_task = tasks.task(workspace_name, project_name, task_name,
                               only_uncompleted: only_uncompleted, section_name: section_name)
    assert_equal(task, returned_task)
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
