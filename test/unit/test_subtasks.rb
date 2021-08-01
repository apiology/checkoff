# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestSubtasks < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :projects)

  let_mock :task, :task_options, :raw_subtasks,
           :subtask,
           :subtask_section_1, :subtask_1a, :subtask_1b,
           :subtask_section_2,
           :subtask_section_3, :subtask_3a

  def test_subtask_section_false
    subtasks = get_test_object do
      subtask.expects(:name).returns('foo')
    end
    refute(subtasks.subtask_section?(subtask))
  end

  def test_subtask_section_true
    subtasks = get_test_object do
      subtask.expects(:name).returns('foo:')
    end
    assert(subtasks.subtask_section?(subtask))
  end

  def expect_subtask_section_1_named
    subtask_section_1.expects(:name).returns('1:').at_least(1)
    subtask_1a.expects(:name).returns('1a')
    subtask_1b.expects(:name).returns('1b')
  end

  def expect_subtask_section_2_named
    subtask_section_2.expects(:name).returns('2:').at_least(1)
  end

  def expect_subtask_section_3_named
    subtask_section_3.expects(:name).returns('3:').at_least(1)
    subtask_3a.expects(:name).returns('3a')
  end

  def expect_subtask_names_queried
    expect_subtask_section_1_named
    expect_subtask_section_2_named
    expect_subtask_section_3_named
  end

  def test_by_section
    subtasks = get_test_object { expect_subtask_names_queried }
    assert_equal({
                   '1:' => [subtask_1a, subtask_1b],
                   '2:' => [],
                   '3:' => [subtask_3a],
                 },
                 subtasks.by_section([subtask_section_1, subtask_1a, subtask_1b,
                                      subtask_section_2,
                                      subtask_section_3, subtask_3a]))
  end

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
