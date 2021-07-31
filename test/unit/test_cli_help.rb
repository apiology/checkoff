# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class with the help option
class TestCLIHelp < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks,
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

  def mock_run_with_no_section_specified_normal_project(due_on:, due_at:)
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

  def get_test_object(&twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks if twiddle_mocks
    Checkoff::CheckoffGLIApp
  end

  def test_run_with_help_arg
    cli = get_test_object do
      @mocks[:stdout].expects(:puts).at_least(1)
    end
    assert_equal(0, cli.run(['--help']))
  end
end
