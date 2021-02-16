# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class
class TestCLI < ClassTest
  let_mock :workspace_name, :workspace, :workspace_gid,
           :task_a, :task_b, :task_c

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

  def expect_three_tasks_queried
    three_tasks.each do |task, task_name|
      expect_task_named(task, task_name)
      expect_task_due_on(task, 'fake_date')
      expect_task_due_at(task, nil)
    end
  end

  def section_name_str
    'section_name:'
  end

  let_mock :project_name

  def expect_three_tasks_pulled_and_queried
    @mocks[:sections].expects(:tasks).with(workspace_name, project_name,
                                           section_name_str)
                     .returns(three_tasks.keys)
    expect_three_tasks_queried
  end

  def mock_run_with_section_specified_normal_project
    project_name.expects(:start_with?).with(':').returns(false)
    expect_three_tasks_pulled_and_queried
  end

  def expected_json_section_specified
    '[{"name":"task_a","due":"fake_date"},' \
    '{"name":"task_b","due":"fake_date"},' \
    '{"name":"task_c","due":"fake_date"}]'
  end

  def test_run_with_section_specified_normal_project
    asana_my_tasks = get_test_object do
      mock_run_with_section_specified_normal_project
    end
    assert_equal(expected_json_section_specified,
                 asana_my_tasks.run(['view',
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

  def mock_run_with_no_section_specified_normal_project
    project_name.expects(:start_with?).with(':').returns(false)
    expect_tasks_by_section_pulled
    expect_three_tasks_queried
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
    end
    assert_raises(SystemExit) do
      asana_my_tasks.run(['view',
                          workspace_name])
    end
  end

  def test_run_with_no_section_specified_normal_project
    asana_my_tasks = get_test_object do
      mock_run_with_no_section_specified_normal_project
    end
    assert_equal(expected_json_no_section_specified,
                 asana_my_tasks.run(['view',
                                     workspace_name,
                                     project_name]))
  end

  def test_run_with_help_arg
    asana_my_tasks = get_test_object do
      @mocks[:stderr].expects(:puts).at_least(1)
    end
    assert_raises(SystemExit) { asana_my_tasks.run(['--help']) }
  end

  def mock_quickadd
    @mocks[:workspaces].expects(:workspace_by_name).with(workspace_name)
                       .returns(workspace)
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

  def class_under_test
    Checkoff::CLI
  end
end
