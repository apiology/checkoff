# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_searches'

class TestTaskSearches < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client, :search_url_parser,
                 :asana_resources_collection_class, :task_selectors)

  let_mock :url, :workspace_name, :workspace, :workspace_gid, :api_params,
           :task_selector, :search_response, :body, :data, :something_else,
           :good_task, :bad_task

  # @return [void]
  def expect_workspace_pulled
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
  end

  # @return [void]
  def expect_workspace_gid_pulled
    # @sg-ignore Unresolved call to workspace
    workspace.expects(:gid).returns('abc')
  end

  # @return [void]
  def expect_convert_params_called
    # @sg-ignore Unresolved call to search_url_parser
    search_url_parser.expects(:convert_params).with(url).returns([api_params, task_selector])
  end

  # @return [void]
  def default_fields
    ['completed_at', 'custom_fields', 'dependencies', 'due_at', 'due_on', 'memberships.project.gid',
     'memberships.project.name', 'memberships.section.name', 'name', 'start_at', 'start_on', 'tags']
  end

  # @return [void]
  def expect_client_get_called
    # @sg-ignore Unresolved call to client
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
      # @sg-ignore Unresolved call to data
      'data' => data,
      # @sg-ignore Unresolved call to something_else
      'something_else' => something_else,
    }
    # @sg-ignore Unresolved call to search_response
    search_response.expects(:body).returns(body).at_least(1)
    # @sg-ignore Unresolved call to data
    body.expects(:fetch).with('data').returns(data)
  end

  # @param response_array [Object]
  # @return [void]
  def expect_response_wrapped(response_array)
    # @sg-ignore Unresolved call to asana_resources_collection_class
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
    # @sg-ignore Unresolved call to task_selectors
    task_selectors
      .expects(:filter_via_task_selector)
      .with(good_task, task_selector)
      .returns(true)
    # @sg-ignore Unresolved call to task_selectors
    task_selectors
      .expects(:filter_via_task_selector)
      .with(bad_task, task_selector)
      .returns(false)
  end

  # @return [void]
  def expect_task_selector_queried
    # @sg-ignore Unresolved call to task_selector
    task_selector.expects(:empty?).returns(false)
  end

  # @return [void]
  def mock_task_search
    expect_workspace_pulled
    expect_workspace_gid_pulled
    expect_convert_params_called
    expect_task_selector_queried
    expect_search_response_queried
    # @sg-ignore Unresolved call to good_task
    # @sg-ignore Unresolved call to bad_task
    expect_response_wrapped([good_task, bad_task])
    expect_tasks_filtered
  end

  # @return [void]
  def projects
    # @sg-ignore Unresolved call to client
    Checkoff::Projects.new(client:)
  end

  # @return [void]
  def test_task_search
    task_searches = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
      mock_task_search
    end

    # @sg-ignore Unresolved call to good_task
    # @sg-ignore Unresolved call to task_search
    assert_equal([good_task], task_searches.task_search(workspace_name, url))
  end

  # @return [void]
  def mock_task_search_overloaded
    expect_workspace_pulled
    expect_workspace_gid_pulled
    expect_convert_params_called
    expect_search_response_queried
    # @sg-ignore Unresolved call to good_task
    expect_response_wrapped(Array.new(100) { good_task })
  end

  # @return [void]
  def test_as_cache_key
    task_searches = get_test_object

    # @sg-ignore Unresolved call to as_cache_key
    assert_empty(task_searches.as_cache_key)
  end

  # @return [void]
  def test_raw_task_search_without_selector
    task_searches = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
    end
    collection = mock('collection')
    collection.expects(:count).returns(1)
    task_searches.expects(:api_task_search_request)
      # @sg-ignore Unresolved call to api_params
      .with(api_params, workspace_gid: 'abc', extra_fields: [])
      .returns(collection)

    # @sg-ignore Unresolved call to api_params
    result = task_searches.send(:raw_task_search, api_params, workspace_gid: 'abc', task_selector: [])

    assert_same(collection, result)
  end

  # @param task_searches [Checkoff::TaskSearches]
  # @return [Array]
  def mock_full_page_raw_task_search(task_searches)
    first_page = mock('first_page')
    first_page.expects(:count).returns(100)
    # @sg-ignore Unresolved call to good_task
    paginated = [good_task]
    task_searches.expects(:api_task_search_request)
      # @sg-ignore Unresolved call to api_params
      .with(api_params, workspace_gid: 'abc', extra_fields: [])
      .returns(first_page)
    task_searches.expects(:iterated_raw_task_search)
      # @sg-ignore Unresolved call to api_params
      .with(api_params, workspace_gid: 'abc', extra_fields: [])
      .returns(paginated)
    paginated
  end

  # @return [void]
  def test_raw_task_search_paginates_when_full_page
    task_searches = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = projects
    end
    paginated = mock_full_page_raw_task_search(task_searches)

    # @sg-ignore Unresolved call to api_params
    result = task_searches.send(:raw_task_search, api_params, workspace_gid: 'abc', task_selector: [])

    assert_equal(paginated, result.to_a)
  end

  # @return [void]
  def class_under_test
    Checkoff::TaskSearches
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
