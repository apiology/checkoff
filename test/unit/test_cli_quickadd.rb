# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'base_cli'

# Test the Checkoff::CLI class with quickadd subcommand
class TestCLIQuickadd < BaseCLI
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
end
