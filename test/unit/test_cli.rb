# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class
# rubocop:disable Metrics/ClassLength
class TestCLI < Minitest::Test
  let_mock :workspace, :workspace_gid, :task_a, :task_b, :task_c,
           :config, :workspaces, :sections, :tasks

  def workspace_name
    'my workspace'
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

  def expect_three_tasks_queried(due_on:, due_at:)
    three_tasks.each do |task, task_name|
      expect_task_named(task, task_name)
      expect_task_due_on(task, due_on)
      expect_task_due_at(task, due_at)
    end
  end

  def section_name_str
    'section_name:'
  end

  def project_name
    'my_project'
  end

  def expect_three_tasks_pulled_and_queried(project_name:,
                                            section_name:,
                                            due_on:,
                                            due_at:)
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

  def expect_tasks_by_section_pulled
    @mocks[:sections]
      .expects(:tasks_by_section)
      .with(workspace_name, project_name)
      .returns(nil => [task_a], section_name_str => [task_b, task_c])
  end

  def mock_run_with_no_section_specified_normal_project(due_on:, due_at:)
    expect_tasks_by_section_pulled
    expect_three_tasks_queried(due_on: due_on, due_at: due_at)
  end

  def expected_json_no_section_specified
    '{"":[{"name":"task_a","due":"fake_date"}],' \
    '"section_name:":[{"name":"task_b","due":"fake_date"},' \
    '{"name":"task_c","due":"fake_date"}]}'
  end

  def mock_run_with_no_project_specified
    @mocks[:stderr].expects(:puts).at_least(1)
  end

  def test_run_with_no_project_specified
    asana_my_tasks = get_test_object do
      mock_run_with_no_project_specified
      @mocks[:stdout].expects(:puts)
    end
    assert_equal(64, asana_my_tasks.run(['view', workspace_name]))
  end

  def expected_json_view_not_due
    '{"":[{"name":"task_a"}],"section_name:":[{"name":"task_b"},{"name":"task_c"}]}'
  end

  def test_view_not_due
    asana_my_tasks = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: nil)
      @mocks[:stdout].expects(:puts).with(expected_json_view_not_due)
    end
    assert_equal(0,
                 asana_my_tasks.run(['view',
                                     workspace_name,
                                     project_name]))
  end

  def expected_json_view_due_at
    '{"":[{"name":"task_a","due":"fake time"}],' \
    '"section_name:":[{"name":"task_b","due":"fake time"},' \
    '{"name":"task_c","due":"fake time"}]}'
  end

  def test_view_due_at
    asana_my_tasks = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: 'fake time')
      @mocks[:stdout].expects(:puts).with(expected_json_view_due_at)
    end
    assert_equal(0,
                 asana_my_tasks.run(['view',
                                     workspace_name,
                                     project_name]))
  end

  def test_run_with_no_section_specified_normal_project
    asana_my_tasks = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: 'fake_date', due_at: nil)
      @mocks[:stdout].expects(:puts).with(expected_json_no_section_specified)
    end
    assert_equal(0,
                 asana_my_tasks.run(['view',
                                     workspace_name,
                                     project_name]))
  end

  def test_run_with_help_arg
    asana_my_tasks = get_test_object do
      @mocks[:stdout].expects(:puts).at_least(1)
    end
    assert_equal(0, asana_my_tasks.run(['--help']))
  end

  def mock_quickadd
    @mocks[:workspaces].expects(:workspace_by_name).with(workspace_name).returns(workspace)

    workspace.expects(:gid).returns(workspace_gid)
    @mocks[:tasks].expects(:add_task).with('my task name',
                                           workspace_gid: workspace_gid)
  end

  def test_quickadd
    asana_my_tasks = get_test_object do
      mock_quickadd
    end
    asana_my_tasks.run(['quickadd', workspace_name, 'my task name'])
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

  def expect_workspaces_created
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  def expect_config_loaded
    Checkoff::ConfigLoader.expects(:load).returns(config).at_least(0)
  end

  def expect_sections_created
    Checkoff::Sections.expects(:new).returns(sections).at_least(0)
  end

  def expect_tasks_created
    Checkoff::Tasks.expects(:new).returns(tasks).at_least(0)
  end

  def get_test_object(&twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks if twiddle_mocks
    Checkoff::CheckoffGLIApp
  end
end
# rubocop:enable Metrics/ClassLength
