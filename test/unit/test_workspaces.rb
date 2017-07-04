# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'base_asana'

# Test the Checkoff::Workspaces class
class TestWorkspaces < BaseAsana
  let_mock :workspace_a_name, :workspace_a, :workspace_a_id,
           :workspace_b_name, :workspace_b, :workspace_b_id,
           :workspaces

  def setup_client_created
    @mocks[:asana_client].expects(:new).yields(client).returns(client)
    @mocks[:config].expects(:[]).with(:personal_access_token)
                   .returns(personal_access_token)
    client.expects(:workspaces).returns(workspaces)
    workspaces.expects(:find_all).returns([workspace_a, workspace_b])
    workspace_a.expects(:name).returns(workspace_a_name)
    client.expects(:authentication).with(:access_token, personal_access_token)
  end

  def mock_workspace_by_name
    setup_client_created
  end

  def test_workspace_by_name
    asana = get_test_object { mock_workspace_by_name }
    assert_equal(workspace_a, asana.workspace_by_name(workspace_a_name))
  end

  def test_default_workspace_id
    asana = get_test_object do
      @mocks[:config].expects(:[]).with(:default_workspace_id)
                     .returns(workspace_a_id)
    end
    assert_equal(workspace_a_id, asana.default_workspace_id)
  end

  def class_under_test
    Checkoff::Workspaces
  end
end
