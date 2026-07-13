# typed: false
# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class with the help option
class TestCLIHelp < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks,
           :workspace, :workspace_gid, :task_a, :task_b, :task_c

  # @return [void]
  def expect_workspaces_created
    # @sg-ignore Unresolved call to workspaces
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  # @return [void]
  def expect_config_loaded
    # @sg-ignore Unresolved call to config
    Checkoff::Internal::ConfigLoader.expects(:load).returns(config).at_least(0)
  end

  # @return [void]
  def expect_sections_created
    # @sg-ignore Unresolved call to sections
    Checkoff::Sections.expects(:new).returns(sections).at_least(0)
  end

  # @return [void]
  def expect_tasks_created
    # @sg-ignore Unresolved call to tasks
    Checkoff::Tasks.expects(:new).returns(tasks).at_least(0)
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
  def get_test_object(&twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks if twiddle_mocks
    Checkoff::CheckoffGLIApp
  end

  # @return [void]
  def test_run_with_help_arg
    cli = get_test_object do
      @mocks[:stdout].expects(:puts).at_least(1)
    end

    # @sg-ignore Unresolved call to run
    assert_equal(0, cli.run(['--help']))
  end
end
