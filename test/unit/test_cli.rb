require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class
class TestCLI < ClassTest
  let_mock :workspace_name, :task_a, :task_b, :task_c

  def expect_task_named(task, task_name)
    task.expects(:name).returns(task_name).at_least(0)
  end

  def three_tasks
    { task_a => 'task_a', task_b => 'task_b', task_c => 'task_c' }
  end

  def expect_three_tasks_named
    three_tasks.each { |task, task_name| expect_task_named(task, task_name) }
  end

  def section_name_str
    'section_name:'
  end

  let_mock :project_name

  def expect_three_tasks_pulled_and_named
    @mocks[:sections].expects(:tasks).with(workspace_name, project_name,
                                           section_name_str)
                     .returns(three_tasks.keys)
    expect_three_tasks_named
  end

  def mock_run_with_section_specified_normal_project
    project_name.expects(:start_with?).with(':').returns(false)
    expect_three_tasks_pulled_and_named
  end

  def test_run_with_section_specified_normal_project
    asana_my_tasks = get_test_object do
      mock_run_with_section_specified_normal_project
    end
    expected_json = '[{"name":"task_a"},{"name":"task_b"},{"name":"task_c"}]'
    assert_equal(expected_json,
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
    expect_three_tasks_named
  end

  def test_run_with_no_section_specified_normal_project
    asana_my_tasks = get_test_object do
      mock_run_with_no_section_specified_normal_project
    end
    expected_json =
      '{"":[{"name":"task_a"}],' \
      '"section_name:":[{"name":"task_b"},{"name":"task_c"}]}'
    assert_equal(expected_json,
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

  def class_under_test
    Checkoff::CLI
  end
end
