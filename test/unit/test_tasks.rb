# frozen_string_literal: true

require_relative 'base_asana'
require 'checkoff/cli'

# Test the Checkoff::Tasks class
class TestTasks < BaseAsana
  let_mock :mock_tasks, :modified_mock_tasks, :tasks_by_section,
           :unflattened_modified_mock_tasks

  def mock_tasks_minus_sections
    @mocks[:sections]
      .expects(:by_section).with(mock_tasks)
      .returns(tasks_by_section)
    tasks_by_section.expects(:values).returns(unflattened_modified_mock_tasks)
    unflattened_modified_mock_tasks
      .expects(:flatten).returns(modified_mock_tasks)
  end

  def test_tasks_minus_sections
    tasks = get_test_object do
      mock_tasks_minus_sections
    end
    assert_equal(modified_mock_tasks,
                 tasks.tasks_minus_sections(mock_tasks))
  end

  let_mock :workspace_id, :task_name, :default_assignee_id

  def expect_task_created
    @mocks[:asana_task].expects(:create).with(client,
                                              assignee: default_assignee_id,
                                              workspace: workspace_id,
                                              name: task_name)
  end

  def mock_add_task
    @mocks[:config].expects(:[]).with(:default_assignee_id)
      .returns(default_assignee_id)
    @mocks[:sections].expects(:client).returns(client)
    expect_task_created
  end

  def test_add_task
    tasks = get_test_object do
      mock_add_task
    end
    tasks.add_task(task_name, workspace_id: workspace_id)
  end

  def class_under_test
    Checkoff::Tasks
  end
end
