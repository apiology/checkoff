# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestTags < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::Tags]
  #  def get_test_object; end

  def_delegators(:@mocks, :workspaces, :client)

  typed_let_mock :workspace_name, String
  typed_let_mock :tag_name, String

  let_mock :tag, :workspace, :workspace_gid,
           :tags_api, :wrong_tag, :wrong_tag_name, :task_collection, :response,
           :parsed_data, :response_body, :response_body_data

  # @return [void]
  def test_tag_or_raise_raises
    tags = get_test_object do
      tag_arr = [wrong_tag]
      expect_tags_pulled(tag_arr)
    end
    assert_raises(RuntimeError) do
      tags.tag_or_raise(workspace_name, tag_name)
    end
  end

  # @return [void]
  def test_tag_or_raise
    tags = get_test_object do
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
    tags = get_test_object do
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
    # @sg-ignore Unresolved call to gid on Mocha::Mock
    "/tags/#{tag.gid}/tasks"
  end

  # @return [void]
  def projects
    # @sg-ignore Wrong argument type for Checkoff::Projects.new: client expected Asana::Client, received Mocha::Mock
    # https://github.com/castwide/solargraph/issues/1229
    Checkoff::Projects.new(client:)
  end

  # @return [void]
  def test_tasks
    tags = get_test_object do
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
    tags = get_test_object do
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

  # @return [void]
  def class_under_test
    Checkoff::Tags
  end
end
