# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/attachments'

class TestAttachments < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :client)

  let_mock :attachment_name, :resource, :parent_gid, :response

  def mock_create_attachment_from_url(url)
    resource.expects(:gid).returns(parent_gid)
    body = {
      'parent' => parent_gid,
      'url' => url,
      'resource_subtype' => 'external',
      'name' => attachment_name,
    }
    client.expects(:post).with('/attachments', body:, options: {}).returns(response)
    attachment_body = {
      'data' => {
        'foo' => 'bar',
      },
    }
    response.expects(:body).returns(attachment_body).at_least(1)
  end

  def test_create_attachment_from_url
    url = 'http://example.com'
    attachments = get_test_object do
      mock_create_attachment_from_url(url)
    end
    attachment = attachments.create_attachment_from_url!(url, resource, attachment_name:, just_the_url: true)

    assert_equal('bar', attachment.foo)
  end

  def class_under_test
    Checkoff::Attachments
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
