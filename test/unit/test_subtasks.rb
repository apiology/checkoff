# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestSubtasks < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :projects)

  let_mock :task, :raw_subtasks,
           :subtask,
           :subtask_section_1, :subtask_1a, :subtask_1b,
           :subtask_section_2,
           :subtask_section_3, :subtask_3a,
           :is_rendered_as_separator

  def task_options
    {
      task_options: true,
      options: {
        task_options_options: true,
        fields: ['task_field'],
      },
    }
  end

  def subtask_options
    {
      task_options: true,
      options: {
        task_options_options: true,
        fields: %w[task_field is_rendered_as_separator],
      },
    }
  end

  # def test_all_subtasks_completed_false
  #   subtasks = get_test_object do
  #     expect_raw_subtasks_pulled
  #     active_subtasks = [subtask_section_1, subtask_1a, subtask_1b,
  #                        subtask_section_2,
  #                        subtask_section_3, subtask_3a]
  #     expect_active_subtasks_pulled(active_subtasks)
  #     allow_all_section_status_queried
  #   end

  #   refute(subtasks.all_subtasks_completed?(task))
  # end

  def expect_active_subtasks_pulled(active_subtasks)
    projects.expects(:active_tasks).with(raw_subtasks).returns(active_subtasks)
  end

  def allow_all_section_status_queried
    allow_subtask_section_status_queried(subtask_section_1, true)
    allow_subtask_section_status_queried(subtask_section_2, true)
    allow_subtask_section_status_queried(subtask_section_3, true)
    allow_subtask_section_status_queried(subtask_1a, false)
    allow_subtask_section_status_queried(subtask_1b, false)
    allow_subtask_section_status_queried(subtask_3a, false)
  end

  # def test_all_subtasks_completed_true
  #   subtasks = get_test_object do
  #     expect_raw_subtasks_pulled
  #     active_subtasks = [subtask_section_1,
  #                        subtask_section_2,
  #                        subtask_section_3]
  #     expect_active_subtasks_pulled(active_subtasks)
  #     allow_all_section_status_queried
  #   end

  #   assert(subtasks.all_subtasks_completed?(task))
  # end

  def allow_subtask_section_status_queried(subtask, result)
    subtask.expects(:is_rendered_as_separator).returns(result).at_least(0)
  end

  # def test_subtask_section
  #   subtasks = get_test_object do
  #     allow_subtask_section_status_queried(subtask, is_rendered_as_separator)
  #   end

  #   assert_equal(subtasks.subtask_section?(subtask), is_rendered_as_separator)
  # end

  def allow_subtask_section_1_named
    subtask_section_1.expects(:name).returns('1:').at_least(0)
    subtask_1a.expects(:name).returns('1a').at_least(0)
    subtask_1b.expects(:name).returns('1b').at_least(0)
  end

  def allow_subtask_section_2_named
    subtask_section_2.expects(:name).returns('2:').at_least(0)
  end

  def allow_subtask_section_3_named
    subtask_section_3.expects(:name).returns('3:').at_least(0)
    subtask_3a.expects(:name).returns('3a').at_least(0)
  end

  def allow_subtask_names_queried
    allow_subtask_section_1_named
    allow_subtask_section_2_named
    allow_subtask_section_3_named
  end

  def mock_by_section
    allow_subtask_names_queried
    allow_all_section_status_queried
  end

  # def test_by_section
  #   subtasks = get_test_object { mock_by_section }

  #   assert_equal({
  #                  nil => [subtask_1a],
  #                  '1:' => [subtask_1b],
  #                  '2:' => [],
  #                  '3:' => [subtask_3a],
  #                },
  #                subtasks.by_section([subtask_1a,
  #                                     subtask_section_1, subtask_1b,
  #                                     subtask_section_2,
  #                                     subtask_section_3, subtask_3a]))
  # end

  # def test_by_section_dupes
  #   subtasks = get_test_object { mock_by_section }
  #   e = assert_raises(RuntimeError) do
  #     subtasks.by_section([subtask_section_1, subtask_1a, subtask_1b,
  #                          subtask_section_1, subtask_1a, subtask_1b,
  #                          subtask_section_2,
  #                          subtask_section_3, subtask_3a])
  #   end

  #   assert_equal('More than one section named 1:', e.message)
  # end

  def expect_raw_subtasks_pulled
    task.expects(:subtasks).with(**subtask_options).returns(raw_subtasks)
  end

  # def test_raw_subtasks
  #   subtasks = get_test_object do
  #     expect_raw_subtasks_pulled
  #   end

  #   assert_equal(raw_subtasks, subtasks.raw_subtasks(task))
  # end

  # def test_init
  #   subtasks = get_test_object

  #   refute_nil subtasks
  # end

  def class_under_test
    Checkoff::Subtasks
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      task_selectors: Checkoff::TaskSelectors,
      projects: Checkoff::Projects,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {
      asana_resources_collection_class: Asana::Resources::Collection,
    }
  end
end
