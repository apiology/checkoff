# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Workspaces class
class TestWorkspaces < BaseAsana
  let_mock :workspace_a_name, :workspace_a, :workspace_a_gid,
           :workspace_b_name, :workspace_b, :workspace_b_gid,
           :workspaces

  def expect_client_object_created
    @mocks[:asana_client].expects(:new).yields(client).returns(client)
  end

  def expect_personal_access_token_pulled
    @mocks[:config].expects(:fetch).with(:personal_access_token)
      .returns(personal_access_token)
  end

  def setup_client_created
    expect_client_object_created
    expect_personal_access_token_pulled
    client.expects(:authentication).with(:access_token, personal_access_token)
    client.expects(:default_headers).with('asana-enable' =>
                                          'string_ids,new_sections')
    client.expects(:default_headers).with('asana-disable' =>
                                          'new_user_task_lists')
  end

  def mock_workspace_by_name
    setup_client_created
    client.expects(:workspaces).returns(workspaces)
    workspaces.expects(:find_all).returns([workspace_a, workspace_b])
    workspace_a.expects(:name).returns(workspace_a_name)
  end

  def test_workspace_by_name
    asana = get_test_object { mock_workspace_by_name }
    assert_equal(workspace_a, asana.workspace_by_name(workspace_a_name))
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
