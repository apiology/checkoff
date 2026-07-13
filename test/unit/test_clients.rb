# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestClients < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :asana_client_class, :config)

  let_mock :client, :personal_access_token

  # @return [void]
  def expect_client_created
    # @sg-ignore asana_client_class comes from def_delegators / let_mock
    asana_client_class.expects(:new).yields(client).returns(client)
  end

  # @return [void]
  def mock_client
    expect_client_created
    # @sg-ignore config/client/personal_access_token from mocks
    config.expects(:fetch).with(:personal_access_token).returns(personal_access_token)
    # @sg-ignore client from let_mock
    client.expects(:authentication).with(:access_token, personal_access_token)
    # @sg-ignore client from let_mock
    client.expects(:default_headers)
      .with('asana-enable' => 'new_project_templates,new_user_task_lists,new_memberships,new_goal_memberships')
  end

  # @return [void]
  def test_client
    clients = get_test_object do
      mock_client
    end

    # @sg-ignore client from let_mock
    assert_equal(client, clients.client)
  end

  # @return [Class]
  def class_under_test
    Checkoff::Clients
  end
end
