# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/attachments'
require 'stringio'

class TestAttachments < ClassTest
  typed_delegate :client, Asana::Client

  typed_mock :resource, Asana::Resources::Task
  typed_mock :attachment_name, String

  typed_mock :parent_gid, String
  typed_mock :response, Asana::HttpClient::Response

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
    attachments = get_test_object(Checkoff::Attachments) do
      mock_create_attachment_from_url(url)
    end
    attachment = attachments.create_attachment_from_url!(url, resource, attachment_name:, just_the_url: true)

    # @sg-ignore test-example
    #   'foo' is an arbitrary JSON field name this test injects into the mocked
    #   response body to prove attribute passthrough works, not a real attribute --
    #   attachment is an Asana::Resources::Resource, whose #method_missing proxies
    #   arbitrary JSON response keys to accessor methods (asana gem's
    #   resource_includes/resource.rb); no fixed method set to annotate.
    assert_equal('bar', attachment.foo)
  end

  # @return [void]
  def test_create_attachment_from_downloaded_url
    url = 'http://example.com/picture.png'
    stub_request(:get, url).to_return(body: 'fake image bytes', status: 200)
    resource.expects(:attach).with(filename: 'custom.png', mime: 'image/png', io: instance_of(File))

    attachments = get_test_object(Checkoff::Attachments)
    attachments.create_attachment_from_url!(url, resource, attachment_name: 'custom.png')
  end

  # @return [void]
  def test_create_attachment_from_downloaded_url_no_host
    attachments = get_test_object(Checkoff::Attachments)

    e = assert_raises(RuntimeError) do
      attachments.create_attachment_from_url!('/no-host-here', resource, attachment_name: 'custom.png')
    end
    assert_match(/URI has no host/, e.message)
  end

  # @return [void]
  def test_create_attachment_from_downloaded_url_bad_response_code
    url = 'http://example.com/picture.png'
    stub_request(:get, url).to_return(body: 'not found', status: 404)

    attachments = get_test_object(Checkoff::Attachments)

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
  # @sg-ignore tool-limitation:gvar-reassignment-not-tracked
  #   TestAttachments#capture_attachments_run return type could not be inferred.
  #   Reassigning a $-prefixed global to a new type is never tracked at all -- unlike an
  #   equivalent local var or ivar reassignment (both work fine), $stdout's new StringIO
  #   type never applies to the reassigned global, so $stdout.string below can't resolve
  #   either. Related to but distinct from castwide/solargraph#663 (that one is about
  #   reading a predefined global never assigned in the file at all, not a
  #   reassignment-tracking gap). Not filed upstream.
  def capture_attachments_run
    old_stdout = $stdout
    $stdout = StringIO.new
    Checkoff::Attachments.run
    # @sg-ignore tool-limitation:gvar-reassignment-not-tracked
    #   Same cause as this method's own sg-ignore above.
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
