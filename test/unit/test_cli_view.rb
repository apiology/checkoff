# typed: false
# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with view subcommand
class TestCLIView < Minitest::Test
  typed_mock :config, Hash
  typed_mock :projects, Checkoff::Projects
  typed_mock :sections, Checkoff::Sections
  typed_mock :tasks, Checkoff::Tasks
  typed_mock :stdout, IO
  typed_mock :task_a, Asana::Resources::Task
  typed_mock :task_b, Asana::Resources::Task
  typed_mock :task_c, Asana::Resources::Task

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
    sections
      .expects(:tasks_by_section)
      .with(workspace_name, project_name)
      .returns(nil => [task_a], section_name_str => [task_b, task_c])
  end

  # @return [void]
  # @param due_on [String, NilClass]
  # @param due_at [String, NilClass]
  def mock_run_with_no_section_specified_normal_project(due_on:, due_at:)
    expect_tasks_by_section_pulled
    expect_three_tasks_queried(due_on:, due_at:)
  end

  # @return [void]
  # @param task_name [String]
  # @param task [Mocha::Mock]
  def expect_task_named(task, task_name)
    task.expects(:name).returns(task_name).at_least(0)
  end

  # @return [void]
  # @param due_on [String, NilClass]
  # @param task [Mocha::Mock]
  def expect_task_due_on(task, due_on)
    task.expects(:due_on).returns(due_on).at_least(0)
  end

  # @return [void]
  # @param task [Mocha::Mock]
  # @param due_at [String, NilClass]
  def expect_task_due_at(task, due_at)
    task.expects(:due_at).returns(due_at).at_least(0)
  end

  # @return [Hash{Object => String}]
  def three_tasks
    { task_a => 'task_a', task_b => 'task_b', task_c => 'task_c' }
  end

  # @return [void]
  # @param task [Mocha::Mock]
  # @param due_at [String, NilClass]
  # @param due_on [String, NilClass]
  # @param task_name [String]
  def expect_task_queried(task, task_name, due_on, due_at)
    expect_task_named(task, task_name)
    expect_task_due_on(task, due_on)
    expect_task_due_at(task, due_at)
  end

  # @param due_on [String, NilClass]
  # @return [void]
  # @param due_at [String, NilClass]
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
  def teardown
    Checkoff::CheckoffGLIApp.subcommand_factory = nil
    super
  end

  # @return [Class<Checkoff::CheckoffGLIApp>]
  def get_test_object(&_twiddle_mocks)
    Checkoff::CheckoffGLIApp.subcommand_factory =
      Checkoff::SubcommandFactory.new(config:, projects:, sections:, tasks:)
    yield if block_given?
    Checkoff::CheckoffGLIApp
  end

  # Kernel#puts in the view action writes to $stdout, so point it at
  # the stdout mock for the duration of the run.
  #
  # @param cli [Class<Checkoff::CheckoffGLIApp>]
  # @param args [Array<String>]
  # @return [void]
  def assert_run_succeeds(cli, args)
    old_stdout = $stdout
    $stdout = stdout
    assert_equal(0, cli.run(args))
  ensure
    $stdout = old_stdout
  end

  # @return [void]
  def test_run_with_no_section_specified_normal_project
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: 'fake_date', due_at: nil)
      stdout.expects(:puts).with(expected_json_no_section_specified)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name])
  end

  # @return [void]
  # @param section_name [String, NilClass]
  # @param due_on [String, NilClass]
  # @param project_name [String, Symbol]
  # @param due_at [String, NilClass]
  def expect_three_tasks_pulled_and_queried(project_name:,
                                            section_name:,
                                            due_on:,
                                            due_at:)
    sections.expects(:tasks).with(workspace_name, project_name,
                                  section_name)
      .returns(three_tasks.keys)
    expect_three_tasks_queried(due_on:, due_at:)
  end

  # @return [void]
  # @param due_at [String, NilClass]
  # @param section_name [String, NilClass]
  # @param project_name [String, Symbol]
  # @param due_on [String, NilClass]
  def mock_view(project_name:, section_name:,
                due_at:, due_on:)
    expect_three_tasks_pulled_and_queried(project_name:,
                                          section_name:,
                                          due_at:,
                                          due_on:)
  end

  # @return [void]
  # @param section_name [String, NilClass]
  def mock_view_specific_task(section_name:)
    tasks.expects(:task).with(workspace_name, project_name, task_name,
                              section_name:).returns(task_a)
    expect_task_queried(task_a, task_name, nil, nil)
    stdout.expects(:puts).with('{"name":"my_task"}')
  end

  # @return [void]
  def test_view_specific_task_nil_section
    cli = get_test_object do
      mock_view_specific_task(section_name: nil)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name,
                              '',
                              task_name])
  end

  # @return [void]
  def test_view_specific_task
    cli = get_test_object do
      mock_view_specific_task(section_name: section_name_str)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name,
                              section_name_str,
                              task_name])
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
      stdout.expects(:puts).with(expected_json_section_specified)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name,
                              ''])
  end

  # @return [void]
  def mock_view_run_with_section_specified_normal_project_colon_project
    mock_view(project_name: project_name.to_sym,
              section_name: section_name_str,
              due_on: 'fake_date',
              due_at: nil)
  end

  # @return [void]
  def test_view_run_with_section_specified_normal_project_colon_project
    cli = get_test_object do
      mock_view_run_with_section_specified_normal_project_colon_project
      stdout.expects(:puts).with(expected_json_section_specified)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              ":#{project_name}",
                              section_name_str])
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
      stdout.expects(:puts).with(expected_json_section_specified)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name,
                              section_name_str])
  end

  # GLI writes usage errors and help to the process's standard streams,
  # bound when the app is defined, so capture at the file-descriptor level.
  #
  # @return [void]
  def test_run_with_no_project_specified
    cli = get_test_object
    exit_code = nil
    out, err = capture_subprocess_io do
      exit_code = cli.run(['view', workspace_name])
    end

    assert_equal(64, exit_code)
    assert_match(/error/, err)
    refute_empty(out)
  end

  # @return [void]
  def expected_json_view_not_due
    '{"":[{"name":"task_a"}],"section_name:":[{"name":"task_b"},{"name":"task_c"}]}'
  end

  # @return [void]
  def test_view_not_due
    cli = get_test_object do
      mock_run_with_no_section_specified_normal_project(due_on: nil, due_at: nil)
      stdout.expects(:puts).with(expected_json_view_not_due)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name])
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
      stdout.expects(:puts).with(expected_json_view_due_at)
    end

    assert_run_succeeds(cli, ['view',
                              workspace_name,
                              project_name])
  end
end
