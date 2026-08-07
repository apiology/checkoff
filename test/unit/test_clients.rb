# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestClients < ClassTest
  typed_delegate :asana_client_class, Class
  typed_delegate :config, Checkoff::Internal::EnvFallbackConfigLoader

  typed_mock :client, Asana::Client
  typed_mock :configuration, Asana::Client::Configuration
  typed_mock :personal_access_token, String

  # @return [void]
  def expect_client_created
    asana_client_class.expects(:new).yields(configuration).returns(client)
  end

  # @return [void]
  def mock_client
    expect_client_created
    config.expects(:fetch).with(:personal_access_token).returns(personal_access_token)
    configuration.expects(:authentication).with(:access_token, personal_access_token)
    configuration.expects(:default_headers)
      .with('asana-enable' => 'new_project_templates,new_user_task_lists,new_memberships,new_goal_memberships')
  end

  # @return [void]
  def test_client
    clients = get_test_object(Checkoff::Clients) do
      mock_client
    end

    assert_equal(client, clients.client)
  end
end
