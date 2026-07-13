# typed: false
# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with view subcommand
class TestCLIView < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks, :clients, :client,
           :workspace, :workspace_gid, :task_a, :task_b, :task_c

  # @return [String]
  def expected_json_no_section_specified
    '{"":[{"name":"task_a","due":"fake_date"}],' \
      '"section_name:":[{"name":"task_b","due":"fake_date"},' \
      '{"name":"task_c","due":"fake_date"}]}'
  end

  # @return [String]
  def section_name_str
    'section_name:'
  end

  # @return [String]
  def project_name
    'my_project'
  end

  # @return [String]
  def task_name
    'my_task'
  end

  # @return [void]
  def expect_tasks_by_section_pulled
    @mocks[:sections]
      .expects(:tasks_by_section)
      .with(workspace_name, project_name)
      # @sg-ignore Unresolved call to task_a
      # @sg-ignore Unresolved call to task_c
      # @sg-ignore Unresolved call to task_b
      .returns(nil => [task_a], section_name_str => [task_b, task_c])
  end

  # @return [void]
  def expect_client_pulled
    # @sg-ignore Unresolved call to clients
    clients.expects(:client).returns(client)
  end

  # @return [void]
  # @param due_on [Object]
  # @param due_at [Object]
  def mock_run_with_no_section_specified_normal_project(due_on:, due_at:)
    expect_client_pulled
    expect_tasks_by_section_pulled
    expect_three_tasks_queried(due_on:, due_at:)
  end

  # @return [void]
  # @param task_name [Object]
  # @param task [Object]
  def expect_task_named(task, task_name)
    task.expects(:name).returns(task_name).at_least(0)
  end

  # @return [void]
  # @param due_on [Object]
  # @param task [Object]
  def expect_task_due_on(task, due_on)
    task.expects(:due_on).returns(due_on).at_least(0)
  end

  # @return [void]
  # @param task [Object]
  # @param due_at [Object]
  def expect_task_due_at(task, due_at)
    task.expects(:due_at).returns(due_at).at_least(0)
  end

  # @return [Hash{Object => String}]
  def three_tasks
    # @sg-ignore Unresolved call to task_c
    # @sg-ignore Unresolved call to task_a
    # @sg-ignore Unresolved call to task_b
    { task_a => 'task_a', task_b => 'task_b', task_c => 'task_c' }
  end

  # @return [void]
  # @param task [Object]
  # @param due_at [Object]
  # @param due_on [Object]
  # @param task_name [Object]
  def expect_task_queried(task, task_name, due_on, due_at)
    expect_task_named(task, task_name)
    expect_task_due_on(task, due_on)
    expect_task_due_at(task, due_at)
  end

  # @param due_on [Object]
  # @return [void]
  # @param due_at [Object]
  def expect_three_tasks_queried(due_on:, due_at:)
    three_tasks.each do |task, task_name|
      expect_task_queried(task, task_name, due_on, due_at)
    end
  end

  # @return [String]
  def workspace_name
    'my workspace'
  end

  # @return [void]
  def allow_workspaces_created
    # @sg-ignore Unresolved call to workspaces
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  # @return [void]
  def allow_config_loaded
    # @sg-ignore Unresolved call to config
    Checkoff::Internal::ConfigLoader.expects(:load).returns(config).at_least(0)
  end

  # @return [void]
  def allow_sections_created
    # @sg-ignore Unresolved call to sections
    Checkoff::Sections.expects(:new).returns(sections).at_least(0)
  end

  # @return [void]
  def allow_tasks_created
    # @sg-ignore Unresolved call to tasks
    Checkoff::Tasks.expects(:new).returns(tasks).at_least(0)
  end

  # @return [void]
  def allow_clients_created
    # @sg-ignore Unresolved call to clients
    Checkoff::Clients.expects(:new).returns(clients).at_least(0)
  end

  # @return [void]
  def set_mocks
    @mocks = {
      # @sg-ignore Unresolved call to config
      config:,
      # @sg-ignore Unresolved call to workspaces
      workspaces:,
      # @sg-ignore Unresolved call to sections
      sections:,
      # @sg-ignore Unresolved call to tasks
      tasks:,
      stderr: $stderr,
      stdout: $stdout,
    }
  end

  # @return [void]
  def get_test_object(&_twiddle_mocks)
    set_mocks
    allow_workspaces_created
    allow_config_loaded
    allow_sections_created
    allow_tasks_created
    allow_clients_created

    yield @mocks
    Checkoff::CheckoffGLIApp
  end

  # @return [void]
  def test_run_with_no_section_specified_normal_project
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: 'fake_date', due_at: nil)
      @mocks[:stdout].expects(:puts).with(expected_json_no_section_specified)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name]))
  end

  # @return [void]
  # @param section_name [String, nil, NilClass]
  # @param due_on [Object]
  # @param project_name [String]
  # @param due_at [Object]
  def expect_three_tasks_pulled_and_queried(project_name:,
                                            section_name:,
                                            due_on:,
                                            due_at:)
    expect_client_pulled
    @mocks[:sections].expects(:tasks).with(workspace_name, project_name,
                                           section_name)
      .returns(three_tasks.keys)
    expect_three_tasks_queried(due_on:, due_at:)
  end

  # @return [void]
  # @param due_at [Object]
  # @param section_name [String, nil, NilClass]
  # @param project_name [String]
  # @param due_on [Object]
  def mock_view(project_name:, section_name:,
                due_at:, due_on:)
    expect_three_tasks_pulled_and_queried(project_name:,
                                          section_name:,
                                          due_at:,
                                          due_on:)
  end

  # @return [void]
  # @param section_name [String, nil, NilClass]
  def mock_view_specific_task(section_name:)
    expect_client_pulled
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:task).with(workspace_name, project_name, task_name,
                              section_name:).returns(task_a)
    # @sg-ignore Unresolved call to task_a
    expect_task_queried(task_a, task_name, nil, nil)
    @mocks[:stdout].expects(:puts).with('{"name":"my_task"}')
  end

  # @return [void]
  def test_view_specific_task_nil_section
    cli = get_test_object do
      mock_view_specific_task(section_name: nil)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          '',
                          task_name]))
  end

  # @return [void]
  def test_view_specific_task
    cli = get_test_object do
      mock_view_specific_task(section_name: section_name_str)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          section_name_str,
                          task_name]))
  end

  # @return [void]
  def expected_json_section_specified
    '[{"name":"task_a","due":"fake_date"},' \
      '{"name":"task_b","due":"fake_date"},' \
      '{"name":"task_c","due":"fake_date"}]'
  end

  # @return [void]
  def mock_view_run_with_section_specified_empty_section
    mock_view(project_name:,
              section_name: nil,
              due_on: 'fake_date',
              due_at: nil)
  end

  # @return [void]
  def test_view_run_with_section_specified_empty_section
    cli = get_test_object do
      mock_view_run_with_section_specified_empty_section
      @mocks[:stdout].expects(:puts).with(expected_json_section_specified)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          '']))
  end

  # @return [void]
  def mock_view_run_with_section_specified_normal_project_colon_project
    # @sg-ignore Unresolved call to to_sym on void
    mock_view(project_name: project_name.to_sym,
              section_name: section_name_str,
              due_on: 'fake_date',
              due_at: nil)
  end

  # @return [void]
  def test_view_run_with_section_specified_normal_project_colon_project
    cli = get_test_object do
      mock_view_run_with_section_specified_normal_project_colon_project
      @mocks[:stdout].expects(:puts).with(expected_json_section_specified)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          ":#{project_name}",
                          section_name_str]))
  end

  # @return [void]
  def mock_view_run_with_section_specified_normal_project
    mock_view(project_name:,
              section_name: section_name_str,
              due_on: 'fake_date',
              due_at: nil)
  end

  # @return [void]
  def test_view_run_with_section_specified_normal_project
    cli = get_test_object do
      mock_view_run_with_section_specified_normal_project
      @mocks[:stdout].expects(:puts).with(expected_json_section_specified)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          section_name_str]))
  end

  # @return [void]
  def mock_run_with_no_project_specified
    @mocks[:stderr].expects(:puts).at_least(1)
  end

  # @return [void]
  def test_run_with_no_project_specified
    cli = get_test_object do
      mock_run_with_no_project_specified
      @mocks[:stdout].expects(:puts)
    end

    # @sg-ignore Unresolved call to run
    assert_equal(64, cli.run(['view', workspace_name]))
  end

  # @return [void]
  def expected_json_view_not_due
    '{"":[{"name":"task_a"}],"section_name:":[{"name":"task_b"},{"name":"task_c"}]}'
  end

  # @return [void]
  def test_view_not_due
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: nil)
      @mocks[:stdout].expects(:puts).with(expected_json_view_not_due)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name]))
  end

  # @return [void]
  def expected_json_view_due_at
    '{"":[{"name":"task_a","due":"fake time"}],' \
      '"section_name:":[{"name":"task_b","due":"fake time"},' \
      '{"name":"task_c","due":"fake time"}]}'
  end

  # @return [void]
  def test_view_due_at
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: 'fake time')
      @mocks[:stdout].expects(:puts).with(expected_json_view_due_at)
    end

    assert_equal(0,
                 # @sg-ignore Unresolved call to run
                 cli.run(['view',
                          workspace_name,
                          project_name]))
  end
end
