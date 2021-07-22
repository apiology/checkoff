# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'active_support'
require 'active_support/time'

# Test the Checkoff::Sections class
class TestSections < BaseAsana
  let_mock :project, :inactive_task_b, :a_membership, :a_membership_project, :a_membership_section,
           :user_task_list_project, :workspace_one, :client, :user_task_lists, :workspace_one_gid,
           :user_task_list, :sections, :section1, :section2, :task_options, :tasks,
           :section1_gid

  def test_section_task_names_no_tasks
    sections = get_test_object do
      mock_tasks_normal_project
      expect_named(task_c, 'c')
    end
    assert_equal(['c'],
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  def test_section_task_names
    sections = get_test_object do
      mock_tasks_normal_project
      expect_named(task_c, 'c')
    end
    assert_equal(['c'],
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  def mock_sections_or_raise
    expect_client_pulled
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [section1, section2])
  end

  def test_sections_or_raise
    sections = get_test_object do
      mock_sections_or_raise
    end
    assert_equal([section1, section2], sections.sections_or_raise('Workspace 1', a_name))
  end

  def test_tasks_by_section
    sections = get_test_object do
      expect_project_a_tasks_pulled
    end
    assert_equal({ 'Section 1:' => [task_c] }, sections.tasks_by_section('Workspace 1', a_name))
  end

  def expect_client_pulled
    @mocks[:projects].expects(:client).returns(client).at_least(1)
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

  def expect_project_gid_pulled(project, gid)
    project.expects(:gid).returns(gid)
  end

  def expect_project_a_tasks_pulled
    expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name)
    expect_project_gid_pulled(project_a, a_gid)
  end

  def expect_sections_client_pulled
    client.expects(:sections).returns(sections)
  end

  def expect_project_sections_pulled(project_gid, sections_array)
    sections.expects(:get_sections_for_project).with(project_gid: project_gid)
      .returns(sections_array)
  end

  def original_task_options
    {
      foo: 'bar',
      per_page: 100,
      options: {
        fields: [],
      },
    }
  end

  def fixed_task_options
    {
      foo: 'bar',
      options: { fields: [] },
    }
  end

  def expect_original_task_options_pulled
    @mocks[:projects].expects(:task_options).with.returns(original_task_options)
  end

  def expect_tasks_api_called_for_section
    tasks.expects(:get_tasks_for_section).with(section_gid: section1_gid,
                                               **fixed_task_options).returns([task_c])
  end

  def expect_section_gid_pulled
    section1.expects(:gid).returns(section1_gid)
  end

  def expect_client_tasks_api_pulled
    client.expects(:tasks).returns(tasks)
  end

  def expect_section_tasks_pulled
    expect_original_task_options_pulled
    expect_client_tasks_api_pulled
    expect_section_gid_pulled
    expect_tasks_api_called_for_section
  end

  def mock_tasks_normal_project
    expect_client_pulled
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_sections_client_pulled
    expect_project_gid_pulled(project_a, a_gid)
    expect_project_sections_pulled(a_gid, [section1, section2])
    section1.expects(:name).returns('Section 1')
    expect_section_tasks_pulled
  end

  let_mock :workspace_1_gid

  def test_tasks_normal_project
    sections = get_test_object do
      mock_tasks_normal_project
    end
    out = sections.tasks('Workspace 1', a_name, 'Section 1:')
    assert_equal([task_c], out)
  end

  def test_tasks_project_not_found
    sections = get_test_object do
      @mocks[:projects]
        .expects(:project).with('Workspace 1', 'not found')
        .returns(nil)
    end
    assert_raises(RuntimeError) do
      # XXX: Deal with colon at end...
      sections.tasks('Workspace 1', 'not found', 'Section 1:')
    end
  end

  let_mock :subtasks

  def class_under_test
    Checkoff::Sections
  end
end
