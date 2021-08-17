# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Workspaces class
class TestWorkspaces < BaseAsana
  extend Forwardable

  def_delegators(:@mocks, :client)

  let_mock :workspace_a_name, :workspace_a, :workspace_a_gid,
           :workspace_b_name, :workspace_b, :workspace_b_gid,
           :workspaces

  def mock_workspace_or_raise_nil
    client.expects(:workspaces).returns(workspaces)
    workspaces.expects(:find_all).returns([workspace_b])
    workspace_b.expects(:name).returns(workspace_b_name)
  end

  def test_workspace_or_raise_nil
    asana = get_test_object { mock_workspace_or_raise_nil }
    assert_raises(RuntimeError) do
      asana.workspace_or_raise(workspace_a_name)
    end
  end

  def mock_workspace_or_raise
    client.expects(:workspaces).returns(workspaces)
    workspaces.expects(:find_all).returns([workspace_a, workspace_b])
    workspace_a.expects(:name).returns(workspace_a_name)
  end

  def test_workspace_or_raise
    asana = get_test_object { mock_workspace_or_raise }
    assert_equal(workspace_a, asana.workspace_or_raise(workspace_a_name))
  end

  def test_default_workspace_gid
    asana = get_test_object do
      @mocks[:config].expects(:fetch).with(:default_workspace_gid)
        .returns(workspace_a_gid)
    end
    assert_equal(workspace_a_gid, asana.send(:default_workspace_gid))
  end

  def class_under_test
    Checkoff::Workspaces
  end
end
