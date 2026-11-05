# typed: false
# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with quickadd subcommand
class TestCLIQuickadd < Minitest::Test
  typed_mock :config, Hash
  typed_mock :workspaces, Checkoff::Workspaces
  typed_mock :tasks, Checkoff::Tasks
  typed_mock :workspace, Asana::Resources::Workspace
  typed_mock :workspace_gid, String

  # @return [void]
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
      Checkoff::SubcommandFactory.new(config:, workspaces:, tasks:)
    yield
    Checkoff::CheckoffGLIApp
  end

  # @return [void]
  def mock_quickadd
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)

    workspace.expects(:gid).returns(workspace_gid)
    tasks.expects(:add_task).with('my task name',
                                  workspace_gid:)
  end

  # @return [void]
  def test_quickadd
    cli = get_test_object do
      mock_quickadd
    end
    cli.run(['quickadd', workspace_name, 'my task name'])
  end
end
