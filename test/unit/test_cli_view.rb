# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with view subcommand
class TestCLIView < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks, :clients, :client,
           :workspace, :workspace_gid, :task_a, :task_b, :task_c

  def expected_json_no_section_specified
    '{"":[{"name":"task_a","due":"fake_date"}],' \
      '"section_name:":[{"name":"task_b","due":"fake_date"},' \
      '{"name":"task_c","due":"fake_date"}]}'
  end

  def section_name_str
    'section_name:'
  end

  def project_name
    'my_project'
  end

  def task_name
    'my_task'
  end

  def expect_tasks_by_section_pulled
    @mocks[:sections]
      .expects(:tasks_by_section)
      .with(workspace_name, project_name)
      .returns(nil => [task_a], section_name_str => [task_b, task_c])
  end

  def expect_client_pulled
    clients.expects(:client).returns(client)
  end

  def mock_run_with_no_section_specified_normal_project(due_on:, due_at:)
    expect_client_pulled
    expect_tasks_by_section_pulled
    expect_three_tasks_queried(due_on: due_on, due_at: due_at)
  end

  def expect_task_named(task, task_name)
    task.expects(:name).returns(task_name).at_least(0)
  end

  def expect_task_due_on(task, due_on)
    task.expects(:due_on).returns(due_on).at_least(0)
  end

  def expect_task_due_at(task, due_at)
    task.expects(:due_at).returns(due_at).at_least(0)
  end

  def three_tasks
    { task_a => 'task_a', task_b => 'task_b', task_c => 'task_c' }
  end

  def expect_task_queried(task, task_name, due_on, due_at)
    expect_task_named(task, task_name)
    expect_task_due_on(task, due_on)
    expect_task_due_at(task, due_at)
  end

  def expect_three_tasks_queried(due_on:, due_at:)
    three_tasks.each do |task, task_name|
      expect_task_queried(task, task_name, due_on, due_at)
    end
  end

  def workspace_name
    'my workspace'
  end

  def allow_workspaces_created
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  def allow_config_loaded
    Checkoff::Internal::ConfigLoader.expects(:load).returns(config).at_least(0)
  end

  def allow_sections_created
    Checkoff::Sections.expects(:new).returns(sections).at_least(0)
  end

  def allow_tasks_created
    Checkoff::Tasks.expects(:new).returns(tasks).at_least(0)
  end

  def allow_clients_created
    Checkoff::Clients.expects(:new).returns(clients).at_least(0)
  end

  def set_mocks
    @mocks = {
      config: config,
      workspaces: workspaces,
      sections: sections,
      tasks: tasks,
      stderr: $stderr,
      stdout: $stdout,
    }
  end

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

  def test_run_with_no_section_specified_normal_project
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: 'fake_date', due_at: nil)
      @mocks[:stdout].expects(:puts).with(expected_json_no_section_specified)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name]))
  end

  def expect_three_tasks_pulled_and_queried(project_name:,
                                            section_name:,
                                            due_on:,
                                            due_at:)
    expect_client_pulled
    @mocks[:sections].expects(:tasks).with(workspace_name, project_name,
                                           section_name)
      .returns(three_tasks.keys)
    expect_three_tasks_queried(due_on: due_on, due_at: due_at)
  end

  def mock_view(project_name:, section_name:,
                due_at:, due_on:)
    expect_three_tasks_pulled_and_queried(project_name: project_name,
                                          section_name: section_name,
                                          due_at: due_at,
                                          due_on: due_on)
  end

  def mock_view_specific_task(section_name:)
    expect_client_pulled
    tasks.expects(:task).with(workspace_name, project_name, task_name,
                              section_name: section_name).returns(task_a)
    expect_task_queried(task_a, task_name, nil, nil)
    @mocks[:stdout].expects(:puts).with('{"name":"my_task"}')
  end

  def test_view_specific_task_nil_section
    cli = get_test_object do
      mock_view_specific_task(section_name: nil)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          '',
                          task_name]))
  end

  def test_view_specific_task
    cli = get_test_object do
      mock_view_specific_task(section_name: section_name_str)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          section_name_str,
                          task_name]))
  end

  def expected_json_section_specified
    '[{"name":"task_a","due":"fake_date"},' \
      '{"name":"task_b","due":"fake_date"},' \
      '{"name":"task_c","due":"fake_date"}]'
  end

  def mock_view_run_with_section_specified_empty_section
    mock_view(project_name: project_name,
              section_name: nil,
              due_on: 'fake_date',
              due_at: nil)
  end

  def test_view_run_with_section_specified_empty_section
    cli = get_test_object do
      mock_view_run_with_section_specified_empty_section
      @mocks[:stdout].expects(:puts).with(expected_json_section_specified)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          '']))
  end

  def mock_view_run_with_section_specified_normal_project_colon_project
    mock_view(project_name: project_name.to_sym,
              section_name: section_name_str,
              due_on: 'fake_date',
              due_at: nil)
  end

  def test_view_run_with_section_specified_normal_project_colon_project
    cli = get_test_object do
      mock_view_run_with_section_specified_normal_project_colon_project
      @mocks[:stdout].expects(:puts).with(expected_json_section_specified)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          ":#{project_name}",
                          section_name_str]))
  end

  def mock_view_run_with_section_specified_normal_project
    mock_view(project_name: project_name,
              section_name: section_name_str,
              due_on: 'fake_date',
              due_at: nil)
  end

  def test_view_run_with_section_specified_normal_project
    cli = get_test_object do
      mock_view_run_with_section_specified_normal_project
      @mocks[:stdout].expects(:puts).with(expected_json_section_specified)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name,
                          section_name_str]))
  end

  def mock_run_with_no_project_specified
    @mocks[:stderr].expects(:puts).at_least(1)
  end

  def test_run_with_no_project_specified
    cli = get_test_object do
      mock_run_with_no_project_specified
      @mocks[:stdout].expects(:puts)
    end
    assert_equal(64, cli.run(['view', workspace_name]))
  end

  def expected_json_view_not_due
    '{"":[{"name":"task_a"}],"section_name:":[{"name":"task_b"},{"name":"task_c"}]}'
  end

  def test_view_not_due
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: nil)
      @mocks[:stdout].expects(:puts).with(expected_json_view_not_due)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name]))
  end

  def expected_json_view_due_at
    '{"":[{"name":"task_a","due":"fake time"}],' \
      '"section_name:":[{"name":"task_b","due":"fake time"},' \
      '{"name":"task_c","due":"fake time"}]}'
  end

  def test_view_due_at
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: 'fake time')
      @mocks[:stdout].expects(:puts).with(expected_json_view_due_at)
    end
    assert_equal(0,
                 cli.run(['view',
                          workspace_name,
                          project_name]))
  end
end
