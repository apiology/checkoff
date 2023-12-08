# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestClients < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :asana_client_class, :config)

  let_mock :client, :personal_access_token

  def expect_client_created
    asana_client_class.expects(:new).yields(client).returns(client)
  end

  def mock_client
    expect_client_created
    config.expects(:fetch).with(:personal_access_token).returns(personal_access_token)
    client.expects(:authentication).with(:access_token, personal_access_token)
    client.expects(:default_headers)
      .with('asana-enable' => 'new_project_templates,new_user_task_lists,new_memberships,new_goal_memberships')
  end

  def test_client
    clients = get_test_object do
      mock_client
    end

    assert_equal(client, clients.client)
  end

  def class_under_test
    Checkoff::Clients
  end
end
