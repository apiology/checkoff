# typed: false
# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with quickadd subcommand
class TestCLIQuickadd < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks,
           :workspace, :workspace_gid, :task_a, :task_b, :task_c

  # @return [void]
  def workspace_name
    'my workspace'
  end

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
  def get_test_object(&_twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks
    Checkoff::CheckoffGLIApp
  end

  # @return [void]
  def mock_quickadd
    # @sg-ignore Unresolved call to workspace
    @mocks[:workspaces].expects(:workspace_or_raise).with(workspace_name).returns(workspace)

    # @sg-ignore Unresolved call to workspace
    workspace.expects(:gid).returns(workspace_gid)
    @mocks[:tasks].expects(:add_task).with('my task name',
                                           # @sg-ignore Unresolved call to workspace_gid
                                           workspace_gid:)
  end

  # @return [void]
  def test_quickadd
    cli = get_test_object do
      mock_quickadd
    end
    # @sg-ignore Unresolved call to run
    cli.run(['quickadd', workspace_name, 'my task name'])
  end
end
