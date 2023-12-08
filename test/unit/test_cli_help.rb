# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class with the help option
class TestCLIHelp < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks,
           :workspace, :workspace_gid, :task_a, :task_b, :task_c

  def expect_workspaces_created
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  def expect_config_loaded
    Checkoff::Internal::ConfigLoader.expects(:load).returns(config).at_least(0)
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
