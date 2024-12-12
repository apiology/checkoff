# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/timelines'

class TestTimelines < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client, :tasks, :sections, :portfolios)

  let_mock :task, :section_2_gid, :section_2, :section_1_gid, :section_1,
           :milestone, :milestone_gid, :task_gid, :portfolio_name, :default_workspace,
           :default_workspace_name, :project_a_gid, :project_a

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
    expect_section_2_previous_section_called
    expect_section_1_gid_pulled
    expect_section_1_tasks_pulled
    expect_milestone_queried
  end

  def test_task_dependent_on_previous_section_last_milestone_false_no_dependencies_
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

  def expect_section_1_gid_pulled
    section_1.expects(:gid).returns(section_1_gid)
  end

  def expect_no_section_1_tasks
    sections.expects(:tasks_by_section_gid).with(section_1_gid,
                                                 extra_fields: ['resource_subtype']).returns([])
  end

  def mock_task_dependent_on_previous_section_last_milestone_true_no_tasks
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
    expect_section_1_gid_pulled
    expect_no_section_1_tasks
  end

  def test_task_dependent_on_previous_section_last_milestone_true_no_tasks
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_true_no_tasks
    end

    assert(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  def expect_section_1_tasks_pulled
    sections.expects(:tasks_by_section_gid)
      .with(section_1_gid, extra_fields: ['resource_subtype'])
      .returns([milestone])
  end

  def expect_milestone_queried
    milestone.expects(:resource_subtype).returns('milestone')
    milestone.expects(:gid).returns(milestone_gid).at_least(0)
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

  def test_last_task_milestone_depends_on_this_task_no_memberships
    timelines = get_test_object do
      task.expects(:memberships).returns([])
    end

    assert(timelines.last_task_milestone_depends_on_this_task?(task))
  end

  def expect_all_dependent_tasks_pulled(task, dependents)
    tasks.expects(:all_dependent_tasks).with(task).returns(dependents)
  end

  def expect_memberships_pulled(task, memberships)
    task.expects(:memberships).returns(memberships)
  end

  def expect_tasks_by_section_gid_pulled(tasks)
    sections.expects(:tasks_by_section_gid)
      .with(section_1_gid, extra_fields: ['resource_subtype'])
      .returns(tasks)
  end

  def expect_milestone_details_pulled
    milestone.expects(:resource_subtype).returns('milestone')
    milestone.expects(:gid).returns(milestone_gid).at_least(1)
  end

  def expect_task_gid_pulled
    task.expects(:gid).returns(task_gid)
  end

  def test_last_task_milestone_depends_on_this_task_false
    timelines = get_test_object do
      expect_all_dependent_tasks_pulled(task, [])
      memberships = [
        {
          'section' => {
            'gid' => section_1_gid,
          },
        },
      ]
      expect_memberships_pulled(task, memberships)
      expect_tasks_by_section_gid_pulled([milestone])
      expect_milestone_details_pulled
      expect_task_gid_pulled
    end

    refute(timelines.last_task_milestone_depends_on_this_task?(task))
  end

  def test_last_task_milestone_depends_on_this_task_no_milestone
    timelines = get_test_object do
      # expect_all_dependent_tasks_pulled(task, [])
      memberships = [
        {
          'section' => {
            'gid' => section_1_gid,
          },
        },
      ]
      expect_memberships_pulled(task, memberships)
      expect_tasks_by_section_gid_pulled([])
    end

    refute(timelines.last_task_milestone_depends_on_this_task?(task))
  end

  def test_last_task_milestone_depends_on_this_task_is_last_milestone
    timelines = get_test_object do
      # expect_all_dependent_tasks_pulled(milestone, [])
      memberships = [
        {
          'section' => {
            'gid' => section_1_gid,
          },
        },
      ]
      expect_memberships_pulled(milestone, memberships)
      expect_tasks_by_section_gid_pulled([milestone])
      expect_milestone_details_pulled
    end

    assert(timelines.last_task_milestone_depends_on_this_task?(milestone))
  end

  def export_portfolio_projects_pulled(projects)
    workspaces.expects(:default_workspace).returns(default_workspace)
    default_workspace.expects(:name).returns(default_workspace_name)
    portfolios.expects(:projects_in_portfolio).with(default_workspace_name,
                                                    portfolio_name).returns(projects)
  end

  def test_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio_no_projects
    timelines = get_test_object do
      # expect_all_dependent_tasks_pulled(milestone, [])
      memberships = [
        {
          'section' => {
            'gid' => section_1_gid,
          },
          'project' => {
            'gid' => project_a_gid,
          },
        },
      ]
      expect_memberships_pulled(milestone, memberships)
      expect_tasks_by_section_gid_pulled([milestone])
      expect_milestone_details_pulled
      export_portfolio_projects_pulled([project_a])
      project_a.expects(:gid).returns(project_a_gid)
    end

    assert(timelines.last_task_milestone_depends_on_this_task?(milestone,
                                                               limit_to_portfolio_name: portfolio_name))
  end

  def mock_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio
    memberships = [
      {
        'section' => {
          'gid' => section_1_gid,
        },
        'project' => {
          'gid' => project_a_gid,
        },
      },
    ]
    expect_memberships_pulled(milestone, memberships)
    export_portfolio_projects_pulled([])
  end

  def test_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio
    timelines = get_test_object do
      mock_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio
    end

    assert(timelines.last_task_milestone_depends_on_this_task?(milestone,
                                                               limit_to_portfolio_name: portfolio_name))
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
      portfolios: Checkoff::Portfolios,
      tasks: Checkoff::Tasks,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
