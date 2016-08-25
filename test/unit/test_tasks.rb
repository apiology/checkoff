# frozen_string_literal: true
require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::Tasks class
class TestTasks < ClassTest
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

  def class_under_test
    Checkoff::Tasks
  end
end
