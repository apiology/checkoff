# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_searches'

class TestTaskSearches < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client, :search_url_parser, :projects,
                 :asana_resources_collection_class, :task_selectors)

  let_mock :url, :workspace_name, :workspace, :workspace_gid, :api_params,
           :task_selector, :search_response, :body, :data, :something_else,
           :good_task, :bad_task

  def expect_workspace_pulled
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
  end

  def expect_workspace_gid_pulled
    workspace.expects(:gid).returns('abc')
  end

  def expect_convert_params_called
    search_url_parser.expects(:convert_params).with(url).returns([api_params, task_selector])
  end

  def expect_task_options_pulled
    projects.expects(:task_options).returns({ options: { fields: [] } })
  end

  def expect_client_get_called
    client
      .expects(:get)
      .with('/workspaces/abc/tasks/search',
            params: api_params, options: { fields: ['custom_fields'] })
      .returns(search_response)
  end

  def expect_search_response_queried
    expect_client_get_called
    body = {
      'data' => data,
      'something_else' => something_else,
    }
    search_response.expects(:body).returns(body).at_least(1)
    body.expects(:fetch).with('data').returns(data)
  end

  def expect_response_wrapped
    asana_resources_collection_class
      .expects(:new)
      .with([data,
             { 'something_else' => something_else }],
            type: Asana::Resources::Task,
            client: client)
      .returns([good_task, bad_task])
  end

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

  def mock_task_search
    expect_workspace_pulled
    expect_workspace_gid_pulled
    expect_convert_params_called
    expect_task_options_pulled
    expect_search_response_queried
    expect_response_wrapped
    expect_tasks_filtered
  end

  def test_task_search
    task_searches = get_test_object do
      mock_task_search
    end
    assert_equal([good_task], task_searches.task_search(workspace_name, url))
  end

  def class_under_test
    Checkoff::TaskSearches
  end
end
