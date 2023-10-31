# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/timelines'

class TestTimelines < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client, :tasks, :sections)

  let_mock :task, :section_2_gid, :section_2, :section_1_gid, :section_1,
           :milestone, :milestone_gid

  # let_mock :workspace_name, :timeline_name, :timeline, :workspace, :workspace_gid,
  #         :timelines_api, :wrong_timeline, :wrong_timeline_name

  # def test_timeline_or_raise_raises
  #   timelines = get_test_object do
  #     timeline_arr = [wrong_timeline]
  #     expect_timelines_pulled(timeline_arr)
  #   end
  #   assert_raises(RuntimeError) do
  #     timelines.timeline_or_raise(workspace_name, timeline_name)
  #   end
  # end

  # def test_timeline_or_raise
  #   timelines = get_test_object do
  #     timeline_arr = [wrong_timeline, timeline]
  #     expect_timelines_pulled(timeline_arr)
  #   end
  #   assert_equal(timeline, timelines.timeline_or_raise(workspace_name, timeline_name))
  # end

  # def expect_workspace_pulled
  #   workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
  #   workspace.expects(:gid).returns(workspace_gid)
  # end

  # def allow_timelines_named
  #   wrong_timeline.expects(:name).returns(wrong_timeline_name).at_least(0)
  #   timeline.expects(:name).returns(timeline_name).at_least(0)
  # end

  # def expect_timelines_pulled(timeline_arr)
  #   expect_workspace_pulled
  #   client.expects(:timelines).returns(timelines_api)
  #   timelines_api.expects(:get_timelines_for_workspace).returns(timeline_arr)
  #   allow_timelines_named
  # end

  # def test_timeline
  #   timelines = get_test_object do
  #     timeline_arr = [wrong_timeline, timeline]
  #     expect_timelines_pulled(timeline_arr)
  #   end
  #   assert_equal(timeline, timelines.timeline(workspace_name, timeline_name))
  # end

  def test_task_dependent_on_previous_section_last_milestone_no_memberships
    timelines = get_test_object do
      expect_task_data_created(task, { 'memberships' => [] })
    end

    assert(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  def mock_task_dependent_on_previous_section_last_milestone_false_no_dependencies
    memberships = [
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [],
    }
    expect_task_data_created(task, task_data)
    sections.expects(:section_by_gid).with(section_2_gid).returns(section_2)
  end

  def test_task_dependent_on_previous_section_last_milestone_false_no_dependencies
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_false_no_dependencies
    end

    refute(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  def expect_task_data_created(task, task_data)
    tasks.expects(:task_to_h).with(task).returns(task_data)
  end

  def expect_section_2_pulled
    sections.expects(:section_by_gid).with(section_2_gid).returns(section_2)
  end

  def expect_section_2_previous_section_called
    sections.expects(:previous_section).with(section_2).returns(section_1)
  end

  def mock_task_dependent_on_previous_section_last_milestone_false_no_tasks
    memberships = [
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [
        {},
      ],
    }
    expect_task_data_created(task, task_data)
    expect_section_2_pulled
    expect_section_2_previous_section_called
    section_1.expects(:gid).returns(section_1_gid)
    sections.expects(:tasks_by_section_gid).with(section_1_gid,
                                                 extra_fields: ['resource_subtype']).returns([])
  end

  def test_task_dependent_on_previous_section_last_milestone_false_no_tasks
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_false_no_tasks
    end

    refute(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  def expect_section_1_gid_pulled
    section_1.expects(:gid).returns(section_1_gid)
  end

  def expect_section_1_tasks_pulled
    sections.expects(:tasks_by_section_gid)
      .with(section_1_gid, extra_fields: ['resource_subtype'])
      .returns([milestone])
  end

  def expect_milestone_queried
    milestone.expects(:resource_subtype).returns('milestone')
    milestone.expects(:gid).returns(milestone_gid)
  end

  def mock_task_dependent_on_previous_section_last_milestone_true
    memberships = [
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [
        { 'gid' => milestone_gid },
      ],
    }
    expect_task_data_created(task, task_data)
    expect_section_2_pulled
    expect_section_2_previous_section_called
    expect_section_1_gid_pulled
    expect_section_1_tasks_pulled
    expect_milestone_queried
  end

  def test_task_dependent_on_previous_section_last_milestone_true
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_true
    end

    assert(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  def mock_task_dependent_on_previous_section_last_milestone_false_no_previous_section
    memberships = [
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [
        { 'gid' => milestone_gid },
      ],
    }
    expect_task_data_created(task, task_data)
    expect_section_2_pulled
    sections.expects(:previous_section).with(section_2).returns(nil)
  end

  def test_task_dependent_on_previous_section_last_milestone_false_no_previous_section
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_false_no_previous_section
    end

    refute(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  def test_init
    timelines = get_test_object

    refute_nil(timelines)
  end

  def class_under_test
    Checkoff::Timelines
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      sections: Checkoff::Sections,
      tasks: Checkoff::Tasks,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
