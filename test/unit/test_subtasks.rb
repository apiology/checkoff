# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestSubtasks < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :projects)

  let_mock :task, :task_options, :raw_subtasks

  def test_raw_subtasks
    subtasks = get_test_object do
      projects.expects(:task_options).returns(task_options)
      task.expects(:subtasks).with(task_options).returns(raw_subtasks)
    end
    assert_equal(raw_subtasks, subtasks.raw_subtasks(task))
  end

  def test_init
    subtasks = get_test_object
    refute subtasks.nil?
  end

  def class_under_test
    Checkoff::Subtasks
  end
end
