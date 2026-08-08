# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'
require 'time'
require 'active_support'
# require 'active_support/time'

# Test the Checkoff::Sections class
class TestSections < BaseAsana
  typed_delegate :workspaces, Checkoff::Workspaces
  typed_delegate :client, Asana::Client

  typed_mock :a_membership_project, Hash
  typed_mock :a_membership_section, Hash

  typed_mock :a_membership, Hash
  typed_mock :sections, Asana::ProxiedResourceClasses::Section
  typed_mock :section_1, Asana::Resources::Section
  typed_mock :section_2, Asana::Resources::Section
  typed_mock :tasks, Asana::ProxiedResourceClasses::Task
  typed_mock :section_1_gid, String
  typed_mock :section_2_gid, String
  typed_mock :recently_assigned, Asana::Resources::Section
  typed_mock :assignee_section, Asana::Resources::Section
  typed_mock :assignee_section_name, String
  typed_mock :empty_section, Asana::Resources::Section
  typed_mock :empty_section_gid, String
  typed_mock :project_gid, String
  typed_mock :get_results, Asana::HttpClient::Response

  # @return [void]
  def test_section_task_names_no_tasks
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: true)
      expect_named(task_c, 'c')
    end

    assert_equal(['c'],
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  # @return [void]
  def projects
    @projects ||= Checkoff::Projects.new(client:)
  end

  # @return [void]
  def test_section_task_names
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: true)
      expect_named(task_c, 'c')
    end

    assert_equal(['c'],
                 sections.section_task_names('Workspace 1', a_name, 'Section 1:'))
  end

  # @return [void]
  def mock_sections_or_raise
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [section_1, section_2])
  end

  # @return [void]
  def test_sections_or_raise
    sections = get_test_object(Checkoff::Sections) do
      mock_sections_or_raise
    end

    assert_equal([section_1, section_2], sections.sections_or_raise('Workspace 1', a_name))
  end

  # @return [void]
  def test_sections_or_raise_nil_project_name
    sections = get_test_object(Checkoff::Sections)
    # @sg-ignore tool-limitation:issue-1265
    #   Unresolved call to sections_or_raise
    assert_raises(ArgumentError) { sections.sections_or_raise('Workspace 1', nil) }
  end

  # @return [void]
  # @param project [Mocha::Mock]
  # @param active_tasks_arr [Array<Mocha::Mock>]
  # @param tasks_arr [Array<Mocha::Mock>]
  def expect_my_tasks_pulled(project, tasks_arr, active_tasks_arr)
    mocks[:projects]
      .expects(:tasks_from_project).with(project,
                                         only_uncompleted: true,
                                         extra_fields: ['assignee_section.name'])
      .returns(tasks_arr)
      .at_least(1)
    mocks[:projects]
      .expects(:active_tasks).with(tasks_arr)
      .returns(active_tasks_arr)
      .at_least(1)
  end

  # @return [void]
  # @param name [String, Mocha::Mock]
  # @param section [Mocha::Mock]
  def expect_section_named(section, name)
    section.expects(:name).returns(name).at_least(1)
  end

  # @return [void]
  # @param section [Mocha::Mock]
  # @param task [Mocha::Mock]
  def expect_assignee_section_pulled(task, section)
    task.expects(:assignee_section).returns(section).at_least(0)
  end

  typed_mock :my_tasks_project, Asana::Resources::Project

  # @return [void]
  def expect_my_tasks_sections_pulled
    expect_sections_client_pulled
    expect_section_named(recently_assigned, 'Recently assigned')
    expect_project_sections_pulled(a_gid, [recently_assigned, assignee_section])
  end

  # @return [void]
  def expect_my_tasks_tasks_pulled
    expect_project_pulled('Workspace 1', my_tasks_project, :my_tasks)
    expect_my_tasks_pulled(my_tasks_project, [task_a, task_b, task_c], [task_c])
    expect_assignee_section_pulled(task_c, assignee_section)
  end

  # @return [void]
  def mock_tasks_by_section_my_tasks
    expect_my_tasks_tasks_pulled
    expect_section_named(assignee_section, assignee_section_name)
    expect_project_gid_pulled(my_tasks_project, a_gid)
    expect_my_tasks_sections_pulled
  end

  # @return [void]
  def test_tasks_by_section_my_tasks
    sections = get_test_object(Checkoff::Sections) do
      mock_tasks_by_section_my_tasks
    end

    assert_equal({ nil => [], assignee_section_name => [task_c] },
                 sections.tasks_by_section('Workspace 1', :my_tasks))
  end

  # @return [void]
  def test_tasks_by_section_nil_workspace_name
    sections = get_test_object(Checkoff::Sections)
    # @sg-ignore tool-limitation:issue-1265
    #   Unresolved call to tasks_by_section
    assert_raises(ArgumentError) { sections.tasks_by_section(nil, :my_tasks) }
  end

  # @return [void]
  def test_tasks_by_section_nil_project_name
    sections = get_test_object(Checkoff::Sections)
    # @sg-ignore tool-limitation:issue-1265
    #   Unresolved call to tasks_by_section
    assert_raises(ArgumentError) { sections.tasks_by_section('Workspace 1', nil) }
  end

  # @return [void]
  def test_tasks_by_section_some_in_empty_section
    sections = get_test_object(Checkoff::Sections) do
      expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name, '(no section)')
      expect_project_gid_pulled(project_a, a_gid)
      expect_sections_client_pulled
      expect_project_sections_pulled(a_gid, [empty_section])
      allow_empty_section_name_pulled
    end

    assert_equal({ nil => [task_c] }, sections.tasks_by_section('Workspace 1', a_name))
  end

  # @return [void]
  def expect_project_a_tasks_pulled
    expect_tasks_and_sections_pulled('Workspace 1', project_a, a_name, 'Section 1')
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [empty_section, section_1])
  end

  # @return [void]
  def test_tasks_by_section
    sections = get_test_object(Checkoff::Sections) do
      expect_project_a_tasks_pulled
      allow_section_1_name_pulled
      allow_empty_section_name_pulled
    end

    assert_equal({ nil => [], 'Section 1' => [task_c] },
                 sections.tasks_by_section('Workspace 1', a_name))
  end

  # @return [void]
  # @param task [Mocha::Mock]
  # @param name [String]
  def expect_named(task, name)
    task.expects(:name).returns(name).at_least(1)
  end

  # @return [void]
  # @param tasks_arr [Array<Mocha::Mock>]
  # @param project [Mocha::Mock]
  # @param active_tasks_arr [Array<Mocha::Mock>]
  def expect_tasks_pulled(project, tasks_arr, active_tasks_arr)
    mocks[:projects]
      .expects(:tasks_from_project).with(project,
                                         only_uncompleted: true,
                                         extra_fields: [])
      .returns(tasks_arr)
      .at_least(1)
    mocks[:projects]
      .expects(:active_tasks).with(tasks_arr)
      .returns(active_tasks_arr)
      .at_least(1)
  end

  # @return [void]
  # @param project [Mocha::Mock]
  # @param project_name [Mocha::Mock, Symbol]
  # @param workspace [String]
  def expect_project_pulled(workspace, project, project_name)
    mocks[:projects]
      .expects(:project).with(workspace, project_name)
      .returns(project)
      .at_least(1)
  end

  # @return [void]
  def expect_task_project_memberships_queried
    a_membership.expects(:fetch).with('project').returns(a_membership_project)
    a_membership_project.expects(:[]).with('gid').returns(a_gid)
  end

  # @return [void]
  # @param section_name [String]
  def expect_task_section_memberships_queried(section_name)
    a_membership.expects(:fetch).with('section').returns(a_membership_section)
    a_membership_section.expects(:fetch).with('name').returns(section_name)
  end

  # @param section_name [String]
  # @return [void]
  def expect_task_memberships_queried(section_name)
    task_c.expects(:memberships).returns([a_membership])
    expect_task_project_memberships_queried
    expect_task_section_memberships_queried(section_name)
  end

  # @param project [Mocha::Mock]
  # @return [void]
  # @param workspace [String]
  # @param project_name [Mocha::Mock]
  # @param section_name [String]
  def expect_tasks_and_sections_pulled(workspace, project, project_name, section_name)
    expect_project_pulled(workspace, project, project_name)
    expect_tasks_pulled(project, [task_a, task_b, task_c],
                        [task_c])
    expect_task_memberships_queried(section_name)
  end

  # @return [void]
  # @param gid [Mocha::Mock]
  # @param project [Mocha::Mock]
  def expect_project_gid_pulled(project, gid)
    project.expects(:gid).returns(gid).at_least(1)
  end

  # @return [void]
  def expect_sections_client_pulled
    client.expects(:sections).returns(sections).at_least(1)
  end

  # @return [void]
  # @param sections_array [Array<Mocha::Mock>]
  # @param project_gid [Mocha::Mock]
  def expect_project_sections_pulled(project_gid, sections_array)
    sections.expects(:get_sections_for_project).with(project_gid:, options: { fields: ['name'] })
      .returns(sections_array).at_least(1)
  end

  # @return [Hash]
  def original_task_options
    {
      per_page: 100,
      options: {
        fields: ['completed_at', 'dependencies', 'due_at', 'due_on', 'memberships.project.gid',
                 'memberships.project.name', 'memberships.section.name', 'name', 'start_at', 'start_on', 'tags'],
      },
    }
  end

  # @param only_uncompleted [Boolean]
  # @return [Hash]
  def fixed_task_options(only_uncompleted:)
    out = original_task_options
    out[:completed_since] = '9999-12-01' if only_uncompleted
    out
  end

  # @return [void]
  # @param task_list [Array<Mocha::Mock>]
  # @param only_uncompleted [Boolean]
  # @param section_gid [Mocha::Mock]
  def expect_tasks_api_called_for_section(section_gid, task_list, only_uncompleted:)
    options = fixed_task_options(only_uncompleted:)
    tasks.expects(:get_tasks).with(section: section_gid,
                                   **options)
      .returns(task_list)
  end

  # @return [void]
  def expect_section_1_gid_pulled
    section_1.expects(:gid).returns(section_1_gid).at_least(1)
  end

  # @return [void]
  def expect_section_2_gid_pulled
    section_2.expects(:gid).returns(section_2_gid).at_least(1)
  end

  # @return [void]
  def expect_client_tasks_api_pulled
    client.expects(:tasks).returns(tasks)
  end

  # @param task_list [Array<Mocha::Mock>]
  # @param only_uncompleted [Boolean]
  # @param section_gid [Mocha::Mock]
  # @param section [Mocha::Mock]
  # @return [void]
  def expect_section_tasks_pulled(section, section_gid, task_list, only_uncompleted:)
    expect_client_tasks_api_pulled
    section.expects(:gid).returns(section_gid).at_least(0)
    expect_tasks_api_called_for_section(section_gid, task_list, only_uncompleted:)
  end

  # @return [void]
  def test_tasks_not_only_uncompleted
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: false)
    end
    out = sections.tasks('Workspace 1', a_name, 'Section 1:',
                         only_uncompleted: false)

    assert_equal([task_c], out)
  end

  # @return [void]
  def allow_section_1_name_pulled
    section_1.expects(:name).returns('Section 1').at_least(0)
  end

  # @return [void]
  def allow_section_2_name_pulled
    section_2.expects(:name).returns('Section 2').at_least(0)
  end

  # @return [void]
  def allow_empty_section_name_pulled
    empty_section.expects(:name).returns('(no section)').at_least(0)
  end

  # @return [void]
  # @param only_uncompleted [Boolean]
  def mock_tasks_normal_project(only_uncompleted:)
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_sections_client_pulled
    expect_project_gid_pulled(project_a, a_gid)
    expect_project_sections_pulled(a_gid, [section_1, section_2])
    allow_section_1_name_pulled
    allow_section_2_name_pulled
    expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                only_uncompleted:)
  end

  # @return [void]
  def test_tasks_normal_project
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      mock_tasks_normal_project(only_uncompleted: true)
    end
    out = sections.tasks('Workspace 1', a_name, 'Section 1:')

    assert_equal([task_c], out)
  end

  # @return [void]
  def test_tasks_by_section_gid
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                  only_uncompleted: true)
    end

    assert_equal([task_c],
                 sections.tasks_by_section_gid(section_1_gid))
  end

  # @return [void]
  def test_tasks_by_section_also_completed
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      expect_section_tasks_pulled(section_1, section_1_gid, [task_c],
                                  only_uncompleted: false)
    end

    assert_equal([task_c],
                 sections.tasks_by_section_gid(section_1_gid,
                                               only_uncompleted: false))
  end

  # @return [void]
  def mock_tasks_inbox
    expect_project_pulled('Workspace 1', project_a, a_name)
    expect_project_gid_pulled(project_a, a_gid)
    expect_sections_client_pulled
    expect_project_sections_pulled(a_gid, [empty_section])
    allow_empty_section_name_pulled
    expect_section_tasks_pulled(empty_section, empty_section_gid, [task_c],
                                only_uncompleted: true)
  end

  # @return [void]
  def test_tasks_inbox
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects] = projects
      mock_tasks_inbox
    end

    assert_equal([task_c], sections.tasks('Workspace 1', a_name, nil))
  end

  # @return [void]
  def test_tasks_section_not_found
    sections = get_test_object(Checkoff::Sections) do
      expect_project_pulled('Workspace 1', project_a, a_name)
      expect_project_gid_pulled(project_a, a_gid)
      expect_sections_client_pulled
      expect_project_sections_pulled(a_gid, [])
    end
    assert_raises(RuntimeError) do
      sections.tasks('Workspace 1', a_name, 'not found')
    end
  end

  # @return [void]
  def test_tasks_project_not_found
    sections = get_test_object(Checkoff::Sections) do
      mocks[:projects]
        .expects(:project).with('Workspace 1', 'not found')
        .returns(nil)
    end
    assert_raises(RuntimeError) do
      # @todo Deal with colon at end...
      sections.tasks('Workspace 1', 'not found', 'Section 1:')
    end
  end

  # @return [void]
  def test_previous_section
    sections = get_test_object(Checkoff::Sections) do
      section_2.expects(:project).returns({ 'gid' => project_gid })
      expect_sections_client_pulled
      expect_project_sections_pulled(project_gid, [section_1, section_2])
      expect_section_1_gid_pulled
      expect_section_2_gid_pulled
    end

    assert_equal(section_1, sections.previous_section(section_2))
  end

  # @return [void]
  def test_previous_section_on_inbox_returns_nil
    sections = get_test_object(Checkoff::Sections) do
      section_1.expects(:project).returns({ 'gid' => project_gid })
      expect_sections_client_pulled
      expect_project_sections_pulled(project_gid, [section_1])
      expect_section_1_gid_pulled
    end

    assert_nil(sections.previous_section(section_1))
  end

  # @return [void]
  def test_section_by_gid
    sections = get_test_object(Checkoff::Sections) do
      client.expects(:get).returns(get_results)
      get_results.expects(:body).returns({ 'data' => { 'gid' => 123 } }).at_least(1)
    end
    section = sections.section_by_gid(section_1_gid)

    # @sg-ignore needs-type-narrowing
    #   Unresolved call to gid -- section is typed Asana::Resources::Section, nil (nilable
    #   union return from Sections#section_by_gid), and this line calls .gid without a nil
    #   guard. Solargraph is correctly refusing to resolve gid through the unnarrowed nil
    #   branch; the fix is a real guard here (e.g. refute_nil(section) before the
    #   assert_equal), not a tool-limitation ignore.
    assert_equal(123, section.gid)
  end

  # @return [void]
  def test_section_by_gid_bad_server_data
    sections = get_test_object(Checkoff::Sections) do
      client.expects(:get).returns(get_results)
      get_results.expects(:body).returns({}).at_least(1)
    end

    e = assert_raises(RuntimeError) { sections.section_by_gid(section_1_gid) }

    assert_equal('Unexpected response body: {}', e.message)
  end

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
end
