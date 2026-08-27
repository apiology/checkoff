# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestTags < ClassTest
  typed_delegate :workspaces, Checkoff::Workspaces
  typed_delegate :client, Asana::Client

  typed_mock :workspace_name, String
  typed_mock :tag_name, String

  typed_mock :tag, Asana::Resources::Tag
  typed_mock :workspace, Asana::Resources::Workspace
  typed_mock :workspace_gid, String
  typed_mock :tags_api, Asana::ProxiedResourceClasses::Tag
  typed_mock :wrong_tag, Asana::Resources::Tag
  typed_mock :wrong_tag_name, String
  typed_mock :task_collection, Asana::Resources::Collection
  typed_mock :response, Asana::HttpClient::Response
  typed_mock :response_body, Hash
  typed_mock :response_body_data, Array

  # @return [void]
  def test_tag_or_raise_raises
    tags = get_test_object(Checkoff::Tags) do
      tag_arr = [wrong_tag]
      expect_tags_pulled(tag_arr)
    end
    assert_raises(RuntimeError) do
      tags.tag_or_raise(workspace_name, tag_name)
    end
  end

  # @return [void]
  def test_tag_or_raise
    tags = get_test_object(Checkoff::Tags) do
      tag_arr = [wrong_tag, tag]
      expect_tags_pulled(tag_arr)
    end

    assert_equal(tag, tags.tag_or_raise(workspace_name, tag_name))
  end

  # @return [void]
  def expect_workspace_pulled
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
    workspace.expects(:gid).returns(workspace_gid)
  end

  # @return [void]
  def allow_tags_named
    wrong_tag.expects(:name).returns(wrong_tag_name).at_least(0)
    tag.expects(:name).returns(tag_name).at_least(0)
  end

  # @return [void]
  # @param tag_arr [Array<Mocha::Mock>]
  def expect_tags_pulled(tag_arr)
    expect_workspace_pulled
    client.expects(:tags).returns(tags_api)
    tags_api.expects(:get_tags_for_workspace).returns(tag_arr)
    allow_tags_named
  end

  # @return [void]
  def test_tag
    tags = get_test_object(Checkoff::Tags) do
      tag_arr = [wrong_tag, tag]
      expect_tags_pulled(tag_arr)
    end

    assert_equal(tag, tags.tag(workspace_name, tag_name))
  end

  # @return [void]
  # @param only_uncompleted [Boolean]
  def mock_tasks(only_uncompleted: true)
    task_params = build_task_params(only_uncompleted)
    merged_task_options = generate_merged_task_options
    task_endpoint = generate_task_endpoint
    response_body = build_response_body

    setup_client_expects(task_endpoint, task_params, merged_task_options)
    setup_response_expects(response_body)
    setup_collection_expects
  end

  # @return [Hash{Symbol => Object}]
  # @param only_uncompleted [Boolean]
  def build_task_params(only_uncompleted)
    # @type [Hash{:limit => Integer} & Hash{:completed_since => String}]
    task_params = { limit: 100 }
    task_params[:completed_since] = '9999-12-01' if only_uncompleted
    task_params
  end

  # @return [Hash{String => Object}]
  def build_response_body
    {
      'data' => response_body_data,
    }
  end

  # @return [void]
  # @param merged_task_options [Hash]
  # @param task_endpoint [String]
  # @param task_params [Hash{Symbol => Object}]
  def setup_client_expects(task_endpoint, task_params, merged_task_options)
    client.expects(:get).with(task_endpoint, params: task_params, options: merged_task_options).returns(response)
  end

  # @return [void]
  # @param response_body [Hash{String => Object}]
  def setup_response_expects(response_body)
    response.expects(:body).returns(response_body).at_least(1)
  end

  # @return [void]
  def setup_collection_expects
    Asana::Resources::Collection.expects(:new).with([response_body_data, {}],
                                                    type: Asana::Resources::Task,
                                                    client:)
      .returns(task_collection)
  end

  # @return [void]
  def generate_task_options
    {
      per_page: 100,
      options: {
        fields: %w[name completed_at due_at due_on tags
                   memberships.project.gid memberships.project.name
                   memberships.section.name dependencies],
      },
    }
  end

  # @return [Hash]
  def generate_merged_task_options
    {
      fields: %w[name completed_at due_at due_on tags
                 memberships.project.gid memberships.project.name
                 memberships.section.name dependencies field1 field2
                 start_at start_on].sort.uniq,
    }
  end

  # @return [String]
  def generate_task_endpoint
    tag.expects(:gid).returns('tag_gid').at_least(1)
    "/tags/#{tag.gid}/tasks"
  end

  # @return [void]
  def projects
    Checkoff::Projects.new(client:)
  end

  # @return [void]
  def test_tasks
    tags = get_test_object(Checkoff::Tags) do
      mocks[:projects] = projects
      mock_tasks(only_uncompleted: true)
    end

    # Stub the tag_or_raise method to return the tag mock object
    tags.stubs(:tag_or_raise).returns(tag)

    # Call the tasks method with the necessary arguments
    result = tags.tasks(workspace_name, tag_name, only_uncompleted: true, extra_fields: %w[field1 field2])

    # Check that the tasks method returned the expected result
    assert_equal(task_collection, result)
  end

  # @return [void]
  def test_tasks_with_completed
    tags = get_test_object(Checkoff::Tags) do
      mocks[:projects] = projects
      mock_tasks(only_uncompleted: false)
    end

    # Stub the tag_or_raise method to return the tag mock object
    tags.stubs(:tag_or_raise).returns(tag)

    # Call the tasks method with the necessary arguments and only_uncompleted set to false
    result = tags.tasks(workspace_name, tag_name, only_uncompleted: false, extra_fields: %w[field1 field2])

    # Check that the tasks method returned the expected result
    assert_equal(task_collection, result)
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      clients: Checkoff::Clients,
      client: Asana::Client,
      projects: Checkoff::Projects,
    }
  end

  def respond_like
    {}
  end
end
