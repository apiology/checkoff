# typed: false
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

  # @sg-ignore Unresolved call to typed_mock
  typed_mock :a_membership_project, Hash
  # @sg-ignore Unresolved call to typed_mock
  typed_mock :a_membership_section, Hash

  let_mock :project, :inactive_task_b, :a_membership,
           :user_task_list_project, :workspace_one, :user_task_lists,
           :workspace_one_gid, :user_task_list, :sections, :section_1,
           :section_2, :tasks, :section_1_gid, :section_2_gid,
           :recently_assigned, :assignee_section,
           :assignee_section_name, :empty_section, :empty_section_gid,
           :project_gid, :get_results

  # @return [void]
  def test_section_task_names_no_tasks
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: true)
      # @sg-ignore Unresolved call to task_c
      expect_named(task_c, 'c')
    end

    assert_equal(['c'],
                 # @sg-ignore Unresolved call to section_task_names
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  # @return [void]
  def projects
    # @sg-ignore Unresolved call to client
    @projects ||= Checkoff::Projects.new(client:)
  end

  # @return [void]
  def test_section_task_names
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: true)
      # @sg-ignore Unresolved call to task_c
      expect_named(task_c, 'c')
    end

    assert_equal(['c'],
                 # @sg-ignore Unresolved call to section_task_names
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  # @return [void]
  def mock_sections_or_raise
    # @sg-ignore Unresolved call to a_name
    # @sg-ignore Unresolved call to project_a
    expect_project_pulled('Workspace 1', project_a, a_name)
    # @sg-ignore Unresolved call to a_gid
    # @sg-ignore Unresolved call to project_a
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    # @sg-ignore Unresolved call to a_gid
    # @sg-ignore Unresolved call to section_2
    # @sg-ignore Unresolved call to section_1
    expect_project_sections_pulled(a_gid, [section_1, section_2])
  end

  # @return [void]
  def test_sections_or_raise
    sections = get_test_object do
      mock_sections_or_raise
    end

    # @sg-ignore Unresolved call to section_2
    # @sg-ignore Unresolved call to sections_or_raise
    # @sg-ignore Unresolved call to section_1
    assert_equal([section_1, section_2], sections.sections_or_raise('Workspace 1', a_name))
  end

  # @return [void]
  def test_sections_or_raise_nil_project_name
    sections = get_test_object
    # @sg-ignore Unresolved call to sections_or_raise
    assert_raises(ArgumentError) { sections.sections_or_raise('Workspace 1', nil) }
  end

  # @return [void]
  # @param project [Object]
  # @param active_tasks_arr [Object]
  # @param tasks_arr [Object]
  def expect_my_tasks_pulled(project, tasks_arr, active_tasks_arr)
    # @sg-ignore Unresolved call to @mocks
    @mocks[:projects]
      .expects(:tasks_from_project).with(project,
                                         only_uncompleted: true,
                                         extra_fields: ['assignee_section.name'])
      .returns(tasks_arr)
      .at_least(1)
    # @sg-ignore Unresolved call to @mocks
    @mocks[:projects]
      .expects(:active_tasks).with(tasks_arr)
      .returns(active_tasks_arr)
      .at_least(1)
  end

  # @return [void]
  # @param name [Object]
  # @param section [Object]
  def expect_section_named(section, name)
    section.expects(:name).returns(name).at_least(1)
  end

  # @return [void]
  # @param section [Object]
  # @param task [Object]
  def expect_assignee_section_pulled(task, section)
    task.expects(:assignee_section).returns(section).at_least(0)
  end

  let_mock :my_tasks_project

  # @return [void]
  def expect_my_tasks_sections_pulled
    expect_sections_client_pulled
    # @sg-ignore Unresolved call to recently_assigned
    expect_section_named(recently_assigned, 'Recently assigned')
    # @sg-ignore Unresolved call to a_gid
    # @sg-ignore Unresolved call to recently_assigned
    # @sg-ignore Unresolved call to assignee_section
    expect_project_sections_pulled(a_gid, [recently_assigned, assignee_section])
  end

  # @return [void]
  def expect_my_tasks_tasks_pulled
    # @sg-ignore Unresolved call to my_tasks_project
    expect_project_pulled('Workspace 1', my_tasks_project, :my_tasks)
    # @sg-ignore Unresolved call to my_tasks_project
    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to task_b
    # @sg-ignore Unresolved call to task_a
    expect_my_tasks_pulled(my_tasks_project, [task_a, task_b, task_c], [task_c])
    # @sg-ignore Unresolved call to assignee_section
    # @sg-ignore Unresolved call to task_c
    expect_assignee_section_pulled(task_c, assignee_section)
  end

  # @return [void]
  def mock_tasks_by_section_my_tasks
    expect_my_tasks_tasks_pulled
    # @sg-ignore Unresolved call to assignee_section
    # @sg-ignore Unresolved call to assignee_section_name
    expect_section_named(assignee_section, assignee_section_name)
    # @sg-ignore Unresolved call to my_tasks_project
    # @sg-ignore Unresolved call to a_gid
    expect_project_gid_pulled(my_tasks_project, a_gid)
    expect_my_tasks_sections_pulled
  end

  # @return [void]
  def test_tasks_by_section_my_tasks
    sections = get_test_object do
      mock_tasks_by_section_my_tasks
    end

    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to assignee_section_name
    assert_equal({ nil => [], assignee_section_name => [task_c] },
                 # @sg-ignore Unresolved call to tasks_by_section
                 sections.tasks_by_section('Workspace 1', :my_tasks))
  end

  # @return [void]
  def test_tasks_by_section_nil_workspace_name
    sections = get_test_object
    # @sg-ignore Unresolved call to tasks_by_section
    assert_raises(ArgumentError) { sections.tasks_by_section(nil, :my_tasks) }
  end

  # @return [void]
  def test_tasks_by_section_nil_project_name
    sections = get_test_object
    # @sg-ignore Unresolved call to tasks_by_section
    assert_raises(ArgumentError) { sections.tasks_by_section('Workspace 1', nil) }
  end

  # @return [void]
  def test_tasks_by_section_some_in_empty_section
    sections = get_test_object do
      # @sg-ignore Unresolved call to project_a
      # @sg-ignore Unresolved call to a_name
      expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name, '(no section)')
      # @sg-ignore Unresolved call to project_a
      # @sg-ignore Unresolved call to a_gid
      expect_project_gid_pulled(project_a, a_gid)
      expect_sections_client_pulled
      # @sg-ignore Unresolved call to empty_section
      # @sg-ignore Unresolved call to a_gid
      expect_project_sections_pulled(a_gid, [empty_section])
      allow_empty_section_name_pulled
    end

    # @sg-ignore Unresolved call to tasks_by_section
    # @sg-ignore Unresolved call to task_c
    assert_equal({ nil => [task_c] }, sections.tasks_by_section('Workspace 1', a_name))
  end

  # @return [void]
  def expect_project_a_tasks_pulled
    # @sg-ignore Unresolved call to a_name
    # @sg-ignore Unresolved call to project_a
    expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name, 'Section 1')
    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to a_gid
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    # @sg-ignore Unresolved call to a_gid
    # @sg-ignore Unresolved call to empty_section
    # @sg-ignore Unresolved call to section_1
    expect_project_sections_pulled(a_gid, [empty_section, section_1])
  end

  # @return [void]
  def test_tasks_by_section
    sections = get_test_object do
      expect_project_a_tasks_pulled
      allow_section_1_name_pulled
      allow_empty_section_name_pulled
    end

    # @sg-ignore Unresolved call to task_c
    assert_equal({ nil => [], 'Section 1' => [task_c] },
                 # @sg-ignore Unresolved call to tasks_by_section
                 sections.tasks_by_section('Workspace 1', a_name))
  end

  # @return [void]
  # @param task [Object]
  # @param name [Object]
  def expect_named(task, name)
    task.expects(:name).returns(name).at_least(1)
  end

  # @return [void]
  # @param tasks_arr [Object]
  # @param project [Object]
  # @param active_tasks_arr [Object]
  def expect_tasks_pulled(project, tasks_arr, active_tasks_arr)
    # @sg-ignore Unresolved call to @mocks
    @mocks[:projects]
      .expects(:tasks_from_project).with(project,
                                         only_uncompleted: true,
                                         extra_fields: [])
      .returns(tasks_arr)
      .at_least(1)
    # @sg-ignore Unresolved call to @mocks
    @mocks[:projects]
      .expects(:active_tasks).with(tasks_arr)
      .returns(active_tasks_arr)
      .at_least(1)
  end

  # @return [void]
  # @param project [Object]
  # @param project_name [Object]
  # @param workspace [Object]
  def expect_project_pulled(workspace, project, project_name)
    # @sg-ignore Unresolved call to @mocks
    @mocks[:projects]
      .expects(:project).with(workspace, project_name)
      .returns(project)
      .at_least(1)
  end

  # @return [void]
  def expect_task_project_memberships_queried
    # @sg-ignore Unresolved call to a_membership
    a_membership.expects(:[]).with('project').returns(a_membership_project)
    # @sg-ignore Unresolved call to a_membership_project
    a_membership_project.expects(:[]).with('gid').returns(a_gid)
  end

  # @return [void]
  # @param section_name [Object]
  def expect_task_section_memberships_queried(section_name)
    # @sg-ignore Unresolved call to a_membership
    a_membership.expects(:[]).with('section').returns(a_membership_section)
    # @sg-ignore Unresolved call to a_membership_section
    a_membership_section.expects(:[]).with('name').returns(section_name)
  end

  # @param section_name [Object]
  # @return [void]
  def expect_task_memberships_queried(section_name)
    # @sg-ignore Unresolved call to task_c
    task_c.expects(:memberships).returns([a_membership])
    expect_task_project_memberships_queried
    expect_task_section_memberships_queried(section_name)
  end

  # @param project [Object]
  # @return [void]
  # @param workspace [Object]
  # @param project_name [Object]
  # @param section_name [Object]
  def expect_tasks_and_sections_pulled(workspace, project, project_name, section_name)
    expect_project_pulled(workspace, project, project_name)
    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to task_b
    # @sg-ignore Unresolved call to task_a
    expect_tasks_pulled(project, [task_a, task_b, task_c],
                        # @sg-ignore Unresolved call to task_c
                        [task_c])
    expect_task_memberships_queried(section_name)
  end

  # @return [void]
  # @param gid [Object]
  # @param project [Object]
  def expect_project_gid_pulled(project, gid)
    project.expects(:gid).returns(gid).at_least(1)
  end

  # @return [void]
  def expect_sections_client_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:sections).returns(sections).at_least(1)
  end

  # @return [void]
  # @param sections_array [Object]
  # @param project_gid [Object]
  def expect_project_sections_pulled(project_gid, sections_array)
    # @sg-ignore Unresolved call to sections
    sections.expects(:get_sections_for_project).with(project_gid:, options: { fields: ['name'] })
      .returns(sections_array).at_least(1)
  end

  # @return [void]
  def original_task_options
    {
      per_page: 100,
      options: {
        fields: ['completed_at', 'dependencies', 'due_at', 'due_on', 'memberships.project.gid',
                 'memberships.project.name', 'memberships.section.name', 'name', 'start_at', 'start_on', 'tags'],
      },
    }
  end

  # @param only_uncompleted [Object]
  # @return [void]
  def fixed_task_options(only_uncompleted:)
    out = original_task_options
    # @sg-ignore Unresolved call to []=
    out[:completed_since] = '9999-12-01' if only_uncompleted
    out
  end

  # @return [void]
  # @param task_list [Object]
  # @param only_uncompleted [Object]
  # @param section_gid [Object]
  def expect_tasks_api_called_for_section(section_gid, task_list, only_uncompleted:)
    options = fixed_task_options(only_uncompleted:)
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:get_tasks).with(section: section_gid,
                                   **options)
      .returns(task_list)
  end

  # @return [void]
  def expect_section_1_gid_pulled
    # @sg-ignore Unresolved call to section_1
    section_1.expects(:gid).returns(section_1_gid).at_least(1)
  end

  # @return [void]
  def expect_section_2_gid_pulled
    # @sg-ignore Unresolved call to section_2
    section_2.expects(:gid).returns(section_2_gid).at_least(1)
  end

  # @return [void]
  def expect_client_tasks_api_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:tasks).returns(tasks)
  end

  # @param task_list [Object]
  # @param only_uncompleted [Object]
  # @param section_gid [Object]
  # @param section [Object]
  # @return [void]
  def expect_section_tasks_pulled(section, section_gid, task_list, only_uncompleted:)
    expect_client_tasks_api_pulled
    section.expects(:gid).returns(section_gid).at_least(0)
    expect_tasks_api_called_for_section(section_gid, task_list, only_uncompleted:)
  end

  # @return [void]
  def test_tasks_not_only_uncompleted
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: false)
    end
    # @sg-ignore Unresolved call to tasks
    out = sections.tasks('Workspace 1', a_name, 'Section 1:',
                         only_uncompleted: false)

    # @sg-ignore Unresolved call to task_c
    assert_equal([task_c], out)
  end

  # @return [void]
  def allow_section_1_name_pulled
    # @sg-ignore Unresolved call to section_1
    section_1.expects(:name).returns('Section 1').at_least(0)
  end

  # @return [void]
  def allow_section_2_name_pulled
    # @sg-ignore Unresolved call to section_2
    section_2.expects(:name).returns('Section 2').at_least(0)
  end

  # @return [void]
  def allow_empty_section_name_pulled
    # @sg-ignore Unresolved call to empty_section
    empty_section.expects(:name).returns('(no section)').at_least(0)
  end

  # @return [void]
  # @param only_uncompleted [Object]
  def mock_tasks_normal_project(only_uncompleted:)
    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to a_name
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_sections_client_pulled
    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to a_gid
    expect_project_gid_pulled(project_a, a_gid)
    # @sg-ignore Unresolved call to section_2
    # @sg-ignore Unresolved call to section_1
    # @sg-ignore Unresolved call to a_gid
    expect_project_sections_pulled(a_gid, [section_1, section_2])
    allow_section_1_name_pulled
    allow_section_2_name_pulled
    # @sg-ignore Unresolved call to section_1_gid
    # @sg-ignore Unresolved call to section_1
    # @sg-ignore Unresolved call to task_c
    expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                only_uncompleted:)
  end

  let_mock :workspace_1_gid

  # @return [void]
  def test_tasks_normal_project
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: true)
    end
    # @sg-ignore Unresolved call to tasks
    out = sections.tasks('Workspace 1', a_name, 'Section 1:')

    # @sg-ignore Unresolved call to task_c
    assert_equal([task_c], out)
  end

  # @return [void]
  def test_tasks_by_section_gid
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      # @sg-ignore Unresolved call to section_1
      # @sg-ignore Unresolved call to task_c
      # @sg-ignore Unresolved call to section_1_gid
      expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                  only_uncompleted: true)
    end

    # @sg-ignore Unresolved call to task_c
    assert_equal([task_c],
                 # @sg-ignore Unresolved call to tasks_by_section_gid
                 sections.tasks_by_section_gid(section_1_gid))
  end

  # @return [void]
  def test_tasks_by_section_also_completed
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      # @sg-ignore Unresolved call to section_1
      # @sg-ignore Unresolved call to task_c
      # @sg-ignore Unresolved call to section_1_gid
      expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                  only_uncompleted: false)
    end

    # @sg-ignore Unresolved call to task_c
    assert_equal([task_c],
                 # @sg-ignore Unresolved call to tasks_by_section_gid
                 sections.tasks_by_section_gid(section_1_gid,
                                               only_uncompleted: false))
  end

  # @return [void]
  def mock_tasks_inbox
    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to a_name
    expect_project_pulled('Workspace 1', project_a, a_name)
    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to a_gid
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    # @sg-ignore Unresolved call to a_gid
    # @sg-ignore Unresolved call to empty_section
    expect_project_sections_pulled(a_gid, [empty_section])
    allow_empty_section_name_pulled
    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to empty_section
    # @sg-ignore Unresolved call to empty_section_gid
    expect_section_tasks_pulled(empty_section, empty_section_gid, [task_c],
                                only_uncompleted: true)
  end

  # @return [void]
  def test_tasks_inbox
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      mock_tasks_inbox
    end

    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to tasks
    assert_equal([task_c], sections.tasks('Workspace 1', a_name, nil))
  end

  # @return [void]
  def test_tasks_section_not_found
    sections = get_test_object do
      # @sg-ignore Unresolved call to a_name
      # @sg-ignore Unresolved call to project_a
      expect_project_pulled('Workspace 1', project_a, a_name)
      # @sg-ignore Unresolved call to a_gid
      # @sg-ignore Unresolved call to project_a
      expect_project_gid_pulled(project_a, a_gid)
      expect_sections_client_pulled
      # @sg-ignore Unresolved call to a_gid
      expect_project_sections_pulled(a_gid, [])
    end
    assert_raises(RuntimeError) do
      # @sg-ignore Unresolved call to tasks
      sections.tasks('Workspace 1', a_name, 'not found')
    end
  end

  # @return [void]
  def test_tasks_project_not_found
    sections = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects]
        .expects(:project).with('Workspace 1', 'not found')
        .returns(nil)
    end
    assert_raises(RuntimeError) do
      # @todo Deal with colon at end...
      # @sg-ignore Unresolved call to tasks
      sections.tasks('Workspace 1', 'not found', 'Section 1:')
    end
  end

  # @return [void]
  def test_previous_section
    sections = get_test_object do
      # @sg-ignore Unresolved call to section_2
      section_2.expects(:project).returns({ 'gid' => project_gid })
      expect_sections_client_pulled
      # @sg-ignore Unresolved call to section_1
      # @sg-ignore Unresolved call to project_gid
      # @sg-ignore Unresolved call to section_2
      expect_project_sections_pulled(project_gid, [section_1, section_2])
      expect_section_1_gid_pulled
      expect_section_2_gid_pulled
    end

    # @sg-ignore Unresolved call to section_1
    # @sg-ignore Unresolved call to previous_section
    assert_equal(section_1, sections.previous_section(section_2))
  end

  # @return [void]
  def test_previous_section_on_inbox_returns_nil
    sections = get_test_object do
      # @sg-ignore Unresolved call to section_1
      section_1.expects(:project).returns({ 'gid' => project_gid })
      expect_sections_client_pulled
      # @sg-ignore Unresolved call to project_gid
      # @sg-ignore Unresolved call to section_1
      expect_project_sections_pulled(project_gid, [section_1])
      expect_section_1_gid_pulled
    end

    # @sg-ignore Unresolved call to previous_section
    assert_nil(sections.previous_section(section_1))
  end

  # @return [void]
  def test_section_by_gid
    sections = get_test_object do
      # @sg-ignore Unresolved call to client
      client.expects(:get).returns(get_results)
      # @sg-ignore Unresolved call to get_results
      get_results.expects(:body).returns({ 'data' => { 'gid' => 123 } }).at_least(1)
    end
    # @sg-ignore Unresolved call to section_by_gid
    section = sections.section_by_gid(section_1_gid)

    # @sg-ignore Unresolved call to gid
    assert_equal(123, section.gid)
  end

  # @return [void]
  def test_section_by_gid_bad_server_data
    sections = get_test_object do
      # @sg-ignore Unresolved call to client
      client.expects(:get).returns(get_results)
      # @sg-ignore Unresolved call to get_results
      get_results.expects(:body).returns({}).at_least(1)
    end

    # @sg-ignore Unresolved call to section_by_gid
    e = assert_raises(RuntimeError) { sections.section_by_gid(section_1_gid) }

    assert_equal('Unexpected response body: {}', e.message)
  end

  let_mock :subtasks

  def respond_like_instance_of
    {
      config: Hash,
      client: Asana::Client,
      projects: Checkoff::Projects,
      workspaces: Checkoff::Workspaces,
    }
  end

  def respond_like
    {
      time: Time,
    }
  end

  # @return [void]
  def class_under_test
    Checkoff::Sections
  end
end
