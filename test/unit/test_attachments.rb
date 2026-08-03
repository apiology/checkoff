# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/attachments'
require 'stringio'

class TestAttachments < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::Attachments]
  #  def get_test_object; end

  def_delegators(:@mocks, :client)

  typed_let_mock :resource, Asana::Resources::Resource
  typed_let_mock :attachment_name, String

  typed_let_mock :parent_gid, String
  typed_let_mock :response, Asana::HttpClient::Response

  # @return [void]
  # @param url [String]
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

  # @return [void]
  def test_create_attachment_from_url
    url = 'http://example.com'
    attachments = get_test_object do
      mock_create_attachment_from_url(url)
    end
    attachment = attachments.create_attachment_from_url!(url, resource, attachment_name:, just_the_url: true)

    # @sg-ignore Unresolved call to foo
    assert_equal('bar', attachment.foo)
  end

  # @return [void]
  def test_create_attachment_from_downloaded_url
    url = 'http://example.com/picture.png'
    # @sg-ignore gem-limitation:webmock
    stub_request(:get, url).to_return(body: 'fake image bytes', status: 200)
    # @sg-ignore gem-limitation:mocha
    resource.expects(:attach).with(filename: 'custom.png', mime: 'image/png', io: instance_of(File))

    attachments = get_test_object
    attachments.create_attachment_from_url!(url, resource, attachment_name: 'custom.png')
  end

  # @return [void]
  def test_create_attachment_from_downloaded_url_no_host
    attachments = get_test_object

    e = assert_raises(RuntimeError) do
      attachments.create_attachment_from_url!('/no-host-here', resource, attachment_name: 'custom.png')
    end
    assert_match(/URI has no host/, e.message)
  end

  # @return [void]
  def test_create_attachment_from_downloaded_url_bad_response_code
    url = 'http://example.com/picture.png'
    # @sg-ignore gem-limitation:webmock
    stub_request(:get, url).to_return(body: 'not found', status: 404)

    attachments = get_test_object

    e = assert_raises(RuntimeError) do
      attachments.create_attachment_from_url!(url, resource, attachment_name: 'custom.png')
    end
    assert_match(/Error downloading/, e.message)
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
  def test_run_task_not_found
    gid = '123'
    url = 'http://example.com'
    tasks_client = mock('tasks_client')
    attachments_client = mock('attachments_client')

    ARGV.replace([gid, url])
    Checkoff::Tasks.expects(:new).returns(tasks_client)
    Checkoff::Attachments.expects(:new).returns(attachments_client)
    tasks_client.expects(:task_by_gid).with(gid).returns(nil)

    e = assert_raises(RuntimeError) { capture_attachments_run }
    assert_match(/Could not find task/, e.message)
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
