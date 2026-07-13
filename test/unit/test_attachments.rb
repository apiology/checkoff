# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/attachments'
require 'stringio'

class TestAttachments < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :client)

  let_mock :attachment_name, :resource, :parent_gid, :response

  # @return [void]
  # @param url [Object]
  def mock_create_attachment_from_url(url)
    # @sg-ignore Unresolved call to resource
    resource.expects(:gid).returns(parent_gid)
    body = {
      # @sg-ignore Unresolved call to parent_gid
      'parent' => parent_gid,
      'url' => url,
      'resource_subtype' => 'external',
      # @sg-ignore Unresolved call to attachment_name
      'name' => attachment_name,
    }
    # @sg-ignore Unresolved call to client
    client.expects(:post).with('/attachments', body:, options: {}).returns(response)
    attachment_body = {
      'data' => {
        'foo' => 'bar',
      },
    }
    # @sg-ignore Unresolved call to response
    response.expects(:body).returns(attachment_body).at_least(1)
  end

  # @return [void]
  def test_create_attachment_from_url
    url = 'http://example.com'
    attachments = get_test_object do
      mock_create_attachment_from_url(url)
    end
    # @sg-ignore Unresolved call to create_attachment_from_url!
    attachment = attachments.create_attachment_from_url!(url, resource, attachment_name:, just_the_url: true)

    # @sg-ignore Unresolved call to foo
    assert_equal('bar', attachment.foo)
  end

  # @param gid [String]
  # @param url [String]
  # @return [Mocha::Mock]
  def expect_run_on_attachment(gid, url)
    task = mock('task')
    attachment = mock('attachment')
    tasks_client = mock('tasks_client')
    attachments_client = mock('attachments_client')

    Checkoff::Tasks.expects(:new).returns(tasks_client)
    tasks_client.expects(:task_by_gid).with(gid).returns(task)
    Checkoff::Attachments.expects(:new).returns(attachments_client)
    attachments_client.expects(:create_attachment_from_url!).with(url, task).returns(attachment)
    attachment.expects(:inspect).returns('#<Attachment>')
    attachment
  end

  # @return [String]
  # @sg-ignore TestAttachments#capture_attachments_run return type could not be inferred
  def capture_attachments_run
    old_stdout = $stdout
    $stdout = StringIO.new
    Checkoff::Attachments.run
    # @sg-ignore Unresolved call to string
    $stdout.string
  ensure
    $stdout = old_stdout if old_stdout
  end

  # @return [void]
  def test_run
    gid = '123'
    url = 'http://example.com'

    ARGV.replace([gid, url])
    expect_run_on_attachment(gid, url)

    assert_match(/#<Attachment>/, capture_attachments_run)
  ensure
    ARGV.replace([$PROGRAM_NAME])
  end

  # @return [void]
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

  # @return [void]
  def respond_like
    {}
  end
end
