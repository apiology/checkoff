# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Workspaces class
class TestWorkspaces < BaseAsana
  extend Forwardable

  def_delegators(:@mocks, :client, :asana_workspace)

  let_mock :workspace_a_name, :workspace_a, :workspace_a_gid,
           :workspace_b_name, :workspace_b, :workspace_b_gid,
           :workspaces, :workspace_a

  # @return [void]
  def mock_workspace_or_raise_nil
    # @sg-ignore Unresolved call to client
    client.expects(:workspaces).returns(workspaces)
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:find_all).returns([workspace_b])
    # @sg-ignore Unresolved call to workspace_b
    workspace_b.expects(:name).returns(workspace_b_name)
  end

  # @return [void]
  def test_workspace_or_raise_nil
    asana = get_test_object { mock_workspace_or_raise_nil }
    assert_raises(RuntimeError) do
      # @sg-ignore Unresolved call to workspace_or_raise
      asana.workspace_or_raise(workspace_a_name)
    end
  end

  # @return [void]
  def mock_workspace_or_raise
    # @sg-ignore Unresolved call to client
    client.expects(:workspaces).returns(workspaces)
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:find_all).returns([workspace_a, workspace_b])
    # @sg-ignore Unresolved call to workspace_a
    workspace_a.expects(:name).returns(workspace_a_name)
  end

  # @return [void]
  def test_workspace_or_raise
    asana = get_test_object { mock_workspace_or_raise }

    # @sg-ignore Unresolved call to workspace_or_raise
    # @sg-ignore Unresolved call to workspace_a
    assert_equal(workspace_a, asana.workspace_or_raise(workspace_a_name))
  end

  # @return [void]
  def expect_default_workspace_gid_config_fetched
    # @sg-ignore Unresolved call to @mocks
    @mocks[:config].expects(:fetch).with(:default_workspace_gid)
      .returns(workspace_a_gid)
  end

  # @return [void]
  def test_default_workspace_gid
    asana = get_test_object do
      expect_default_workspace_gid_config_fetched
    end

    # @sg-ignore Unresolved call to workspace_a_gid
    assert_equal(workspace_a_gid, asana.send(:default_workspace_gid))
  end

  # @return [void]
  def test_default_workspace
    asana = get_test_object do
      expect_default_workspace_gid_config_fetched
      # @sg-ignore Unresolved call to asana_workspace
      asana_workspace.expects(:find_by_id).with(client, workspace_a_gid).returns(workspace_a)
    end

    # @sg-ignore Unresolved call to default_workspace
    # @sg-ignore Unresolved call to workspace_a
    assert_equal(workspace_a, asana.default_workspace)
  end

  # @return [void]
  def class_under_test
    Checkoff::Workspaces
  end
end
