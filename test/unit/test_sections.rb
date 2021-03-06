# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'active_support'
require 'active_support/time'

# Test the Checkoff::Sections class
class TestSections < BaseAsana
  let_mock :project, :inactive_task_b, :a_membership, :a_membership_project, :a_membership_section,
           :user_task_list_project, :workspace_one, :client, :user_task_lists, :workspace_one_gid, :user_task_list

  def expect_workspace_pulled(workspace_name, workspace)
    @mocks[:workspaces].expects(:workspace_by_name).with(workspace_name).returns(workspace)
  end

  def expect_legacy_project_and_workspace_pulled(workspace_name, workspace, project, project_name)
    expect_project_pulled(workspace_name, project, project_name)
    expect_workspace_pulled(workspace_name, workspace)
  end

  def expect_client_pulled
    @mocks[:projects].expects(:client).returns(client)
  end

  def expect_user_task_lists_object_pulled_from_client
    client.expects(:user_task_lists).returns(user_task_lists)
  end

  def expect_user_task_lists_queried
    user_task_lists.expects(:get_user_task_list_for_user).with(user_gid: 'me',
                                                               workspace: workspace_one_gid)
      .returns(user_task_list)
  end

  def expect_user_task_list_pulled
    expect_client_pulled
    expect_user_task_lists_object_pulled_from_client
    workspace_one.expects(:gid).returns(workspace_one_gid)
    expect_user_task_lists_queried
    user_task_list.expects(:migration_status).returns('not_migrated')
  end

  def mock_tasks_by_section_my_tasks_legacy
    expect_legacy_project_and_workspace_pulled('Workspace 1',
                                               workspace_one,
                                               user_task_list_project,
                                               :my_tasks)
    expect_user_task_list_pulled
    expect_tasks_pulled(user_task_list_project, [task_c], [task_c])
    expect_named(task_c, 'c')
  end

  def test_tasks_by_section_my_tasks_legacy
    asana = get_test_object do
      mock_tasks_by_section_my_tasks_legacy
    end
    out = asana.tasks_by_section('Workspace 1', :my_tasks)
    assert_equal({ nil => [task_c] }, out)
  end

  def mock_project_task_names
    expect_project_a_tasks_pulled
    expect_named(task_c, 'c')
  end

  def test_project_task_names
    asana = get_test_object do
      mock_project_task_names
    end
    out = asana.send(:project_task_names, 'Workspace 1', a_name)
    assert_equal(['Section 1:', ['c']], out)
  end

  def expect_named(task, name)
    task.expects(:name).returns(name).at_least(1)
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

  def expect_project_pulled(workspace, project, project_name)
    @mocks[:projects]
      .expects(:project).with(workspace, project_name)
      .returns(project)
      .at_least(1)
  end

  def expect_task_project_memberships_queried
    a_membership.expects(:[]).with('project').returns(a_membership_project)
    a_membership_project.expects(:[]).with('gid').returns(a_gid)
  end

  def expect_task_section_memberships_queried
    a_membership.expects(:[]).with('section').returns(a_membership_section)
    a_membership_section.expects(:[]).with('name').returns('Section 1:')
  end

  def expect_task_memberships_queried
    task_c.expects(:memberships).returns([a_membership])
    expect_task_project_memberships_queried
    expect_task_section_memberships_queried
  end

  def expect_tasks_and_sections_pulled(workspace, project, project_name)
    expect_project_pulled(workspace, project, project_name)
    expect_tasks_pulled(project, [task_a, task_b, section_one, task_c],
                        [task_c])
    expect_task_memberships_queried
  end

  def expect_project_a_tasks_pulled
    expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name)
    project_a.expects(:gid).returns(a_gid)
  end

  def mock_section_pulled
    expect_project_a_tasks_pulled
  end

  let_mock :workspace_1_gid

  def test_tasks_normal_project
    asana = get_test_object do
      mock_section_pulled
    end
    out = asana.tasks('Workspace 1', a_name, 'Section 1:')
    assert_equal([task_c], out)
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

  def class_under_test
    Checkoff::Sections
  end
end
