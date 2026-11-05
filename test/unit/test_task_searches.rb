# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_searches'

class TestTaskSearches < ClassTest
  typed_delegate :workspaces, Checkoff::Workspaces
  typed_delegate :client, Asana::Client
  typed_delegate :search_url_parser, Checkoff::Internal::SearchUrl::Parser
  typed_delegate :asana_resources_collection_class, Class
  typed_delegate :task_selectors, Checkoff::TaskSelectors

  typed_mock :workspace_name, String
  typed_mock :url, String

  typed_mock :workspace, Asana::Resources::Workspace
  typed_mock :api_params, Hash
  typed_mock :task_selector, Array
  typed_mock :search_response, Asana::HttpClient::Response
  typed_mock :data, Array
  typed_mock :good_task, Asana::Resources::Task
  typed_mock :bad_task, Asana::Resources::Task

  typed_mock :something_else, Object

  # @return [void]
  def expect_workspace_pulled
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
  end

  # @return [void]
  def expect_workspace_gid_pulled
    workspace.expects(:gid).returns('abc')
  end

  # @return [void]
  def expect_convert_params_called
    search_url_parser.expects(:convert_params).with(url).returns([api_params, task_selector])
  end

  # @return [void]
  def default_fields
    ['completed_at', 'custom_fields', 'dependencies', 'due_at', 'due_on', 'memberships.project.gid',
     'memberships.project.name', 'memberships.section.name', 'name', 'start_at', 'start_on', 'tags']
  end

  # @return [void]
  def expect_client_get_called
    client
      .expects(:get)
      .with('/workspaces/abc/tasks/search',
            params: api_params, options: { fields: default_fields })
      .returns(search_response)
  end

  # @return [void]
  def expect_search_response_queried
    expect_client_get_called
    body = {
      'data' => data,
      'something_else' => something_else,
    }
    search_response.expects(:body).returns(body).at_least(1)
  end

  # @param response_array [Array<Mocha::Mock>]
  # @return [void]
  def expect_response_wrapped(response_array)
    asana_resources_collection_class
      .expects(:new)
      .with([data,
             { 'something_else' => something_else }],
            type: Asana::Resources::Task,
            client:)
      .returns(response_array)
  end

  # @return [void]
  def expect_tasks_filtered
    task_selectors
      .expects(:filter_via_task_selector)
      .with(good_task, task_selector)
      .returns(true)
    task_selectors
      .expects(:filter_via_task_selector)
      .with(bad_task, task_selector)
      .returns(false)
  end

  # @return [void]
  def expect_task_selector_queried
    task_selector.expects(:empty?).returns(false)
  end

  # @return [void]
  def mock_task_search
    expect_workspace_pulled
    expect_workspace_gid_pulled
    expect_convert_params_called
    expect_task_selector_queried
    expect_search_response_queried
    expect_response_wrapped([good_task, bad_task])
    expect_tasks_filtered
  end

  # @return [Checkoff::Projects]
  def projects
    Checkoff::Projects.new(client:)
  end

  # @return [void]
  def test_task_search
    task_searches = get_test_object(Checkoff::TaskSearches) do
      mocks[:projects] = projects
      mock_task_search
    end

    assert_equal([good_task], task_searches.task_search(workspace_name, url))
  end

  # @return [void]
  def mock_task_search_overloaded
    expect_workspace_pulled
    expect_workspace_gid_pulled
    expect_convert_params_called
    expect_search_response_queried
    expect_response_wrapped(Array.new(100) { good_task })
  end

  # @return [void]
  def test_as_cache_key
    task_searches = get_test_object(Checkoff::TaskSearches)

    assert_empty(task_searches.as_cache_key)
  end

  # @param params [Hash{String => Object}]
  # @param extra_fields [Array<String>]
  # @param data [Array]
  # @param result [Enumerable, Mocha::Mock]
  # @return [void]
  def expect_search_request(params, extra_fields:, data:, result:)
    response = mock('response')
    client.expects(:get)
      .with('/workspaces/abc/tasks/search',
            params:, options: { fields: projects.task_fields(extra_fields: ['custom_fields'] + extra_fields) })
      .returns(response)
    response.expects(:body).returns({ 'data' => data }).at_least(1)
    asana_resources_collection_class.expects(:new)
      .with([data, {}], type: Asana::Resources::Task, client:)
      .returns(result)
  end

  # @return [void]
  def test_raw_task_search_without_selector
    task_searches = get_test_object(Checkoff::TaskSearches) do
      mocks[:projects] = projects
    end
    collection = mock('collection')
    collection.expects(:count).returns(1)
    expect_search_request(api_params, extra_fields: [], data: [1], result: collection)

    result = task_searches.send(:raw_task_search, api_params, workspace_gid: 'abc', task_selector: [])

    assert_same(collection, result)
  end

  # @return [void]
  def mock_full_page_raw_task_search
    first_page = mock('first_page')
    first_page.expects(:count).returns(100)
    expect_search_request({}, extra_fields: [], data: [1], result: first_page)
    expect_search_request({ 'sort_by' => 'created_at' },
                          extra_fields: ['created_at'], data: [2], result: [good_task])
    good_task.expects(:created_at).returns('2026-01-01T00:00:00.000Z')
    expect_search_request({ 'sort_by' => 'created_at', 'created_at.before' => '2026-01-01T00:00:00.000Z' },
                          extra_fields: ['created_at'], data: [3], result: [])
  end

  # @return [void]
  def test_raw_task_search_paginates_when_full_page
    task_searches = get_test_object(Checkoff::TaskSearches) do
      mocks[:projects] = projects
    end
    mock_full_page_raw_task_search

    result = task_searches.send(:raw_task_search, {}, workspace_gid: 'abc', task_selector: [])

    assert_equal([good_task], result.to_a)
  end

  # @return [void]
  def test_iterated_raw_task_search
    task_searches = get_test_object(Checkoff::TaskSearches) do
      mocks[:projects] = projects
    end
    expect_search_request({ 'sort_by' => 'created_at' },
                          extra_fields: ['created_at'], data: [1], result: [good_task])
    good_task.expects(:created_at).returns('2026-01-01T00:00:00.000Z')
    expect_search_request({ 'sort_by' => 'created_at', 'created_at.before' => '2026-01-01T00:00:00.000Z' },
                          extra_fields: ['created_at'], data: [2], result: [])

    result = task_searches.send(:iterated_raw_task_search, {}, workspace_gid: 'abc', extra_fields: [])

    assert_equal([good_task], result)
  end

  # @return [void]
  def mock_iterated_raw_task_search_task_without_created_at
    expect_search_request({ 'sort_by' => 'created_at' },
                          extra_fields: ['created_at'], data: [1], result: [good_task])
    good_task.expects(:created_at).returns(nil)
    good_task.expects(:gid).returns('123')
  end

  # @return [void]
  def test_iterated_raw_task_search_task_without_created_at
    task_searches = get_test_object(Checkoff::TaskSearches) do
      mocks[:projects] = projects
    end
    mock_iterated_raw_task_search_task_without_created_at

    e = assert_raises(RuntimeError) do
      task_searches.send(:iterated_raw_task_search, {}, workspace_gid: 'abc', extra_fields: [])
    end

    assert_equal('Task 123 has no created_at', e.message)
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      task_selectors: Checkoff::TaskSelectors,
      projects: Checkoff::Projects,
      clients: Checkoff::Clients,
      search_url_parser: Checkoff::Internal::SearchUrl::Parser,
      client: Asana::Client,
    }
  end

  def respond_like
    {
      asana_resources_collection_class: Asana::Resources::Collection,
    }
  end
end
