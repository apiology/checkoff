# typed: false
# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with quickadd subcommand
class TestCLIQuickadd < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks,
           :workspace, :workspace_gid, :task_a, :task_b, :task_c

  def workspace_name
    'my workspace'
  end

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
      config:,
      workspaces:,
      sections:,
      tasks:,
      stderr: $stderr,
      stdout: $stdout,
    }
  end

  def get_test_object(&_twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks
    Checkoff::CheckoffGLIApp
  end

  def mock_quickadd
    @mocks[:workspaces].expects(:workspace_or_raise).with(workspace_name).returns(workspace)

    workspace.expects(:gid).returns(workspace_gid)
    @mocks[:tasks].expects(:add_task).with('my task name',
                                           workspace_gid:)
  end

  def test_quickadd
    cli = get_test_object do
      mock_quickadd
    end
    cli.run(['quickadd', workspace_name, 'my task name'])
  end
end
