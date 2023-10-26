# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'time'
require 'active_support'
# require 'active_support/time'

# Test the Checkoff::Sections class
class TestSections < BaseAsana
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client)

  let_mock :project, :inactive_task_b, :a_membership,
           :a_membership_project, :a_membership_section,
           :user_task_list_project, :workspace_one, :user_task_lists,
           :workspace_one_gid, :user_task_list, :sections, :section_1,
           :section_2, :task_options, :tasks, :section_1_gid, :section_2_gid,
           :recently_assigned, :assignee_section,
           :assignee_section_name, :empty_section, :empty_section_gid, :project_gid,
           :get_results

  def test_section_task_names_no_tasks
    sections = get_test_object do
      mock_tasks_normal_project(only_uncompleted: true)
      expect_named(task_c, 'c')
    end

    assert_equal(['c'],
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  def test_section_task_names
    sections = get_test_object do
      mock_tasks_normal_project(only_uncompleted: true)
      expect_named(task_c, 'c')
    end

    assert_equal(['c'],
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  def mock_sections_or_raise
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [section_1, section_2])
  end

  def test_sections_or_raise
    sections = get_test_object do
      mock_sections_or_raise
    end

    assert_equal([section_1, section_2], sections.sections_or_raise('Workspace 1', a_name))
  end

  def test_sections_or_raise_nil_project_name
    sections = get_test_object
    assert_raises(ArgumentError) { sections.sections_or_raise('Workspace 1', nil) }
  end

  def expect_my_tasks_pulled(project, tasks_arr, active_tasks_arr)
    @mocks[:projects]
      .expects(:tasks_from_project).with(project,
                                         only_uncompleted: true,
                                         extra_fields: ['assignee_section.name'])
      .returns(tasks_arr)
      .at_least(1)
    @mocks[:projects]
      .expects(:active_tasks).with(tasks_arr)
      .returns(active_tasks_arr)
      .at_least(1)
  end

  def expect_section_named(section, name)
    section.expects(:name).returns(name).at_least(1)
  end

  def expect_assignee_section_pulled(task, section)
    task.expects(:assignee_section).returns(section).at_least(0)
  end

  let_mock :my_tasks_project

  def expect_my_tasks_sections_pulled
    expect_sections_client_pulled
    expect_section_named(recently_assigned, 'Recently assigned')
    expect_project_sections_pulled(a_gid, [recently_assigned, assignee_section])
  end

  def expect_my_tasks_tasks_pulled
    expect_project_pulled('Workspace 1', my_tasks_project, :my_tasks)
    expect_my_tasks_pulled(my_tasks_project, [task_a, task_b, task_c], [task_c])
    expect_assignee_section_pulled(task_c, assignee_section)
  end

  def mock_tasks_by_section_my_tasks
    expect_my_tasks_tasks_pulled
    expect_section_named(assignee_section, assignee_section_name)
    expect_project_gid_pulled(my_tasks_project, a_gid)
    expect_my_tasks_sections_pulled
  end

  def test_tasks_by_section_my_tasks
    sections = get_test_object do
      mock_tasks_by_section_my_tasks
    end

    assert_equal({ nil => [], assignee_section_name => [task_c] },
                 sections.tasks_by_section('Workspace 1', :my_tasks))
  end

  def test_tasks_by_section_nil_workspace_name
    sections = get_test_object
    assert_raises(ArgumentError) { sections.tasks_by_section(nil, :my_tasks) }
  end

  def test_tasks_by_section_nil_project_name
    sections = get_test_object
    assert_raises(ArgumentError) { sections.tasks_by_section('Workspace 1', nil) }
  end

  def test_tasks_by_section_some_in_empty_section
    sections = get_test_object do
      expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name, '(no section)')
      expect_project_gid_pulled(project_a, a_gid)
      expect_sections_client_pulled
      expect_project_sections_pulled(a_gid, [empty_section])
      allow_empty_section_name_pulled
    end

    assert_equal({ nil => [task_c] }, sections.tasks_by_section('Workspace 1', a_name))
  end

  def expect_project_a_tasks_pulled
    expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name, 'Section 1')
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [empty_section, section_1])
  end

  def test_tasks_by_section
    sections = get_test_object do
      expect_project_a_tasks_pulled
      allow_section_1_name_pulled
      allow_empty_section_name_pulled
    end

    assert_equal({ nil => [], 'Section 1' => [task_c] },
                 sections.tasks_by_section('Workspace 1', a_name))
  end

  def expect_named(task, name)
    task.expects(:name).returns(name).at_least(1)
  end

  def expect_tasks_pulled(project, tasks_arr, active_tasks_arr)
    @mocks[:projects]
      .expects(:tasks_from_project).with(project,
                                         only_uncompleted: true,
                                         extra_fields: [])
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

  def expect_task_section_memberships_queried(section_name)
    a_membership.expects(:[]).with('section').returns(a_membership_section)
    a_membership_section.expects(:[]).with('name').returns(section_name)
  end

  def expect_task_memberships_queried(section_name)
    task_c.expects(:memberships).returns([a_membership])
    expect_task_project_memberships_queried
    expect_task_section_memberships_queried(section_name)
  end

  def expect_tasks_and_sections_pulled(workspace, project, project_name, section_name)
    expect_project_pulled(workspace, project, project_name)
    expect_tasks_pulled(project, [task_a, task_b, task_c],
                        [task_c])
    expect_task_memberships_queried(section_name)
  end

  def expect_project_gid_pulled(project, gid)
    project.expects(:gid).returns(gid).at_least(1)
  end

  def expect_sections_client_pulled
    client.expects(:sections).returns(sections).at_least(1)
  end

  def expect_project_sections_pulled(project_gid, sections_array)
    sections.expects(:get_sections_for_project).with(project_gid: project_gid, options: { fields: ['name'] })
      .returns(sections_array).at_least(1)
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

  def fixed_task_options(only_uncompleted:)
    out = original_task_options
    out[:completed_since] = '9999-12-01' if only_uncompleted
    out
  end

  def expect_original_task_options_pulled
    @mocks[:projects].expects(:task_options).with.returns(original_task_options)
  end

  def expect_tasks_api_called_for_section(section_gid, task_list, only_uncompleted:)
    options = fixed_task_options(only_uncompleted: only_uncompleted)
    tasks.expects(:get_tasks).with(section: section_gid,
                                   **options)
      .returns(task_list)
  end

  def expect_section_1_gid_pulled
    section_1.expects(:gid).returns(section_1_gid).at_least(1)
  end

  def expect_section_2_gid_pulled
    section_2.expects(:gid).returns(section_2_gid).at_least(1)
  end

  def expect_client_tasks_api_pulled
    client.expects(:tasks).returns(tasks)
  end

  def expect_section_tasks_pulled(section, section_gid, task_list, only_uncompleted:)
    expect_original_task_options_pulled
    expect_client_tasks_api_pulled
    section.expects(:gid).returns(section_gid).at_least(0)
    expect_tasks_api_called_for_section(section_gid, task_list, only_uncompleted: only_uncompleted)
  end

  def test_tasks_not_only_uncompleted
    sections = get_test_object do
      mock_tasks_normal_project(only_uncompleted: false)
    end
    out = sections.tasks('Workspace 1', a_name, 'Section 1:',
                         only_uncompleted: false)

    assert_equal([task_c], out)
  end

  def allow_section_1_name_pulled
    section_1.expects(:name).returns('Section 1').at_least(0)
  end

  def allow_section_2_name_pulled
    section_2.expects(:name).returns('Section 2').at_least(0)
  end

  def allow_empty_section_name_pulled
    empty_section.expects(:name).returns('(no section)').at_least(0)
  end

  def mock_tasks_normal_project(only_uncompleted:)
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_sections_client_pulled
    expect_project_gid_pulled(project_a, a_gid)
    expect_project_sections_pulled(a_gid, [section_1, section_2])
    allow_section_1_name_pulled
    allow_section_2_name_pulled
    expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                only_uncompleted: only_uncompleted)
  end

  let_mock :workspace_1_gid

  def test_tasks_normal_project
    sections = get_test_object do
      mock_tasks_normal_project(only_uncompleted: true)
    end
    out = sections.tasks('Workspace 1', a_name, 'Section 1:')

    assert_equal([task_c], out)
  end

  def test_tasks_by_section_gid
    sections = get_test_object do
      expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                  only_uncompleted: true)
    end

    assert_equal([task_c],
                 sections.tasks_by_section_gid(section_1_gid))
  end

  def test_tasks_by_section_also_completed
    sections = get_test_object do
      expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                  only_uncompleted: false)
    end

    assert_equal([task_c],
                 sections.tasks_by_section_gid(section_1_gid,
                                               only_uncompleted: false))
  end

  def mock_tasks_inbox
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [empty_section])
    allow_empty_section_name_pulled
    expect_section_tasks_pulled(empty_section, empty_section_gid, [task_c],
                                only_uncompleted: true)
  end

  def test_tasks_inbox
    sections = get_test_object do
      mock_tasks_inbox
    end

    assert_equal([task_c], sections.tasks('Workspace 1', a_name, nil))
  end

  def test_tasks_section_not_found
    sections = get_test_object do
      expect_project_pulled('Workspace 1', project_a, a_name)
      expect_project_gid_pulled(project_a, a_gid)
      expect_sections_client_pulled
      expect_project_sections_pulled(a_gid, [])
    end
    assert_raises(RuntimeError) do
      sections.tasks('Workspace 1', a_name, 'not found')
    end
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

  def test_previous_section
    sections = get_test_object do
      section_2.expects(:project).returns({ 'gid' => project_gid })
      expect_sections_client_pulled
      expect_project_sections_pulled(project_gid, [section_1, section_2])
      expect_section_1_gid_pulled
      expect_section_2_gid_pulled
    end

    assert_equal(section_1, sections.previous_section(section_2))
  end

  def test_previous_section_on_inbox_returns_nil
    sections = get_test_object do
      section_1.expects(:project).returns({ 'gid' => project_gid })
      expect_sections_client_pulled
      expect_project_sections_pulled(project_gid, [section_1])
      expect_section_1_gid_pulled
    end

    assert_nil(sections.previous_section(section_1))
  end

  def test_section_by_gid
    sections = get_test_object do
      client.expects(:get).returns(get_results)
      get_results.expects(:body).returns({ 'data' => { 'gid' => 123 } }).at_least(1)
    end
    section = sections.section_by_gid(section_1_gid)

    assert_equal(123, section.gid)
  end

  def test_section_by_gid_bad_server_data
    sections = get_test_object do
      client.expects(:get).returns(get_results)
      get_results.expects(:body).returns({}).at_least(1)
    end

    e = assert_raises(RuntimeError) { sections.section_by_gid(section_1_gid) }
    assert_equal('Unexpected response body: {}', e.message)
  end

  let_mock :subtasks

  def class_under_test
    Checkoff::Sections
  end
end
