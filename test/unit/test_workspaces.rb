# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Workspaces class
class TestWorkspaces < BaseAsana
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::Workspaces]
  #  def get_test_object; end

  def_delegators(:@mocks, :client, :asana_workspace)

  typed_let_mock :workspace_a_name, String
  typed_let_mock :workspace_a, Asana::Resources::Workspace
  typed_let_mock :workspace_a_gid, String
  typed_let_mock :workspace_b_name, String
  typed_let_mock :workspace_b, Asana::Resources::Workspace
  typed_let_mock :workspace_b_gid, String

  let_mock :workspaces

  # @return [void]
  def mock_workspace_or_raise_nil
    client.expects(:workspaces).returns(workspaces)
    workspaces.expects(:find_all).returns([workspace_b])
    workspace_b.expects(:name).returns(workspace_b_name)
  end

  # @return [void]
  def test_workspace_or_raise_nil
    asana = get_test_object { mock_workspace_or_raise_nil }
    assert_raises(RuntimeError) do
      asana.workspace_or_raise(workspace_a_name)
    end
  end

  # @return [void]
  def mock_workspace_or_raise
    client.expects(:workspaces).returns(workspaces)
    workspaces.expects(:find_all).returns([workspace_a, workspace_b])
    workspace_a.expects(:name).returns(workspace_a_name)
  end

  # @return [void]
  def test_workspace_or_raise
    asana = get_test_object { mock_workspace_or_raise }

    assert_equal(workspace_a, asana.workspace_or_raise(workspace_a_name))
  end

  # @return [void]
  def expect_default_workspace_gid_config_fetched
    mocks[:config].expects(:fetch).with(:default_workspace_gid)
      .returns(workspace_a_gid)
  end

  # @return [void]
  def test_default_workspace_gid
    asana = get_test_object do
      expect_default_workspace_gid_config_fetched
    end

    assert_equal(workspace_a_gid, asana.send(:default_workspace_gid))
  end

  # @return [void]
  def test_default_workspace
    asana = get_test_object do
      expect_default_workspace_gid_config_fetched
      asana_workspace.expects(:find_by_id).with(client, workspace_a_gid).returns(workspace_a)
    end

    assert_equal(workspace_a, asana.default_workspace)
  end

  # @return [void]
  def class_under_test
    Checkoff::Workspaces
  end
end
