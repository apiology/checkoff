# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/task_searches'

class TestTaskSearches < ClassTest
  extend Forwardable

  # def_delegators(:@mocks, :workspaces, :client)

  # let_mock :workspace_name, :task_search_name, :task_search, :workspace, :workspace_gid,
  #          :task_searches_api, :wrong_task_search, :wrong_task_search_name

  # def expect_workspace_pulled
  #   workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
  #   workspace.expects(:gid).returns(workspace_gid)
  # end

  # def allow_task_searches_named
  #   wrong_task_search.expects(:name).returns(wrong_task_search_name).at_least(0)
  #   task_search.expects(:name).returns(task_search_name).at_least(0)
  # end

  # def expect_task_searches_pulled(task_search_arr)
  #   expect_workspace_pulled
  #   client.expects(:task_searches).returns(task_searches_api)
  #   task_searches_api.expects(:get_task_searches_for_workspace).returns(task_search_arr)
  #   allow_task_searches_named
  # end

  # def test_task_search
  #   task_searches = get_test_object do
  #     task_search_arr = [wrong_task_search, task_search]
  #     expect_task_searches_pulled(task_search_arr)
  #   end
  #   assert_equal(task_search, task_searches.task_search(workspace_name, task_search_name))
  # end

  # def test_convert_args
  #   task_searches = get_test_object
  #   assert_equal(asana_api_params, task_searches.convert_args(url))
  # end

  def class_under_test
    Checkoff::TaskSearches
  end
end
