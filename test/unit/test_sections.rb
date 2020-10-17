# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Sections class
class TestSections < BaseAsana
  def expect_named(task, name)
    task.expects(:name).returns(name).at_least(1)
  end

  def expect_section_1_queried
    expect_named(section_1, 'Section 1:')
  end

  def expect_tasks_pulled(project, tasks_arr, active_tasks_arr)
    @mocks[:projects]
      .expects(:tasks_from_project).with(project)
      .returns(tasks_arr)
      .at_least(1)
    @mocks[:projects]
      .expects(:active_tasks).with(tasks_arr)
      .returns(active_tasks_arr)
      .at_least(1)
  end

  def expect_tasks_and_sections_pulled(workspace, project, project_name)
    @mocks[:projects]
      .expects(:project).with(workspace, project_name)
      .returns(project)
      .at_least(1)
    expect_tasks_pulled(project, [task_a, task_b, section_1, task_c],
                        [section_1, task_c])
    expect_section_1_queried
    expect_named(task_c, 'task c')
  end

  def expect_project_a_tasks_pulled
    expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name)
    project_a.expects(:gid).returns(a_gid)
    section_1.expects(:memberships).returns([{  }])
  end

  def mock_section_pulled
    expect_project_a_tasks_pulled
  end

  let_mock :workspace_1_gid

  def mock_tasks_on_my_tasks(assignee_status, project_sym)
    expect_tasks_and_sections_pulled('My Workspace', my_tasks_in_workspace,
                                     project_sym)
    section_1.expects(:assignee_status).returns(assignee_status)
    task_c.expects(:assignee_status).returns(assignee_status)
  end

  def test_tasks_project_not_found
    asana = get_test_object do
      @mocks[:projects]
        .expects(:project).with('Workspace 1', 'not found')
        .returns(nil)
    end
    assert_raises(RuntimeError) do
      # XXX: Deal with colon at end...
      asana.tasks('Workspace 1', 'not found', 'Section 1:')
    end
  end

  def test_task_due_by_default
    asana = get_test_object do
      task_a.expects(:due_at).returns(nil)
      task_a.expects(:due_on).returns(nil)
    end
    assert(asana.task_due?(task_a))
  end

  def expect_today_pulled
    @mocks[:time].expects(:today).returns(mock_date)
  end

  def mock_task_due_by_due_on
    task_a.expects(:due_at).returns(nil)
    task_a
      .expects(:due_on)
      .returns((mock_date - 1.day).to_s)
      .at_least(1)
    expect_today_pulled
  end

  def test_task_due_by_due_on
    asana = get_test_object { mock_task_due_by_due_on }
    assert(asana.task_due?(task_a))
  end

  def expect_now_pulled
    @mocks[:time].expects(:now).returns(mock_now).at_least(0)
  end

  def test_task_due_by_due_at
    asana = get_test_object do
      expect_now_pulled
      task_a
        .expects(:due_at).returns((mock_now - 1.minute).to_s).at_least(1)
    end
    assert(asana.task_due?(task_a))
  end

  let_mock :subtasks

  let_mock :task_options

  def mock_raw_subtasks
    @mocks[:projects].expects(:task_options).returns(task_options)
    task_a.expects(:subtasks).with(task_options).returns(subtasks)
    task_a.expects(:name).returns('task a').at_least(0)
  end

  def test_raw_subtasks
    asana = get_test_object { mock_raw_subtasks }
    assert_equal(subtasks, asana.raw_subtasks(task_a))
  end

  def class_under_test
    Checkoff::Sections
  end
end
