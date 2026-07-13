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

  # @return [void]
  def test_task_dependent_on_previous_section_last_milestone_no_memberships
    timelines = get_test_object do
      # @sg-ignore Unresolved call to task
      expect_task_data_created(task, { 'memberships' => [] })
    end

    # @sg-ignore Unresolved call to task_dependent_on_previous_section_last_milestone?
    assert(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  # @return [void]
  def mock_task_dependent_on_previous_section_last_milestone_false_no_dependencies
    memberships = [
      # @sg-ignore Unresolved call to section_2_gid
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [],
    }
    # @sg-ignore Unresolved call to task
    expect_task_data_created(task, task_data)
    # @sg-ignore Unresolved call to sections
    sections.expects(:section_by_gid).with(section_2_gid).returns(section_2)
    expect_section_2_previous_section_called
    expect_section_1_gid_pulled
    expect_section_1_tasks_pulled
    expect_milestone_queried
  end

  # @return [void]
  def test_task_dependent_on_previous_section_last_milestone_false_no_dependencies_
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_false_no_dependencies
    end

    # @sg-ignore Unresolved call to task_dependent_on_previous_section_last_milestone?
    refute(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  # @return [void]
  # @param task [Object]
  # @param task_data [Object]
  def expect_task_data_created(task, task_data)
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:task_to_h).with(task).returns(task_data)
  end

  # @return [void]
  def expect_section_2_pulled
    # @sg-ignore Unresolved call to sections
    sections.expects(:section_by_gid).with(section_2_gid).returns(section_2)
  end

  # @return [void]
  def expect_section_2_previous_section_called
    # @sg-ignore Unresolved call to sections
    sections.expects(:previous_section).with(section_2).returns(section_1)
  end

  # @return [void]
  def expect_section_1_gid_pulled
    # @sg-ignore Unresolved call to section_1
    section_1.expects(:gid).returns(section_1_gid)
  end

  # @return [void]
  def expect_no_section_1_tasks
    # @sg-ignore Unresolved call to sections
    sections.expects(:tasks_by_section_gid).with(section_1_gid,
                                                 extra_fields: ['resource_subtype']).returns([])
  end

  # @return [void]
  def mock_task_dependent_on_previous_section_last_milestone_true_no_tasks
    memberships = [
      # @sg-ignore Unresolved call to section_2_gid
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [
        {},
      ],
    }
    # @sg-ignore Unresolved call to task
    expect_task_data_created(task, task_data)
    expect_section_2_pulled
    expect_section_2_previous_section_called
    expect_section_1_gid_pulled
    expect_no_section_1_tasks
  end

  # @return [void]
  def test_task_dependent_on_previous_section_last_milestone_true_no_tasks
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_true_no_tasks
    end

    # @sg-ignore Unresolved call to task_dependent_on_previous_section_last_milestone?
    assert(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  # @return [void]
  def expect_section_1_tasks_pulled
    # @sg-ignore Unresolved call to sections
    sections.expects(:tasks_by_section_gid)
      .with(section_1_gid, extra_fields: ['resource_subtype'])
      .returns([milestone])
  end

  # @return [void]
  def expect_milestone_queried
    # @sg-ignore Unresolved call to milestone
    milestone.expects(:resource_subtype).returns('milestone')
    # @sg-ignore Unresolved call to milestone
    milestone.expects(:gid).returns(milestone_gid).at_least(0)
  end

  # @return [void]
  def mock_task_dependent_on_previous_section_last_milestone_true
    memberships = [
      # @sg-ignore Unresolved call to section_2_gid
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [
        # @sg-ignore Unresolved call to milestone_gid
        { 'gid' => milestone_gid },
      ],
    }
    # @sg-ignore Unresolved call to task
    expect_task_data_created(task, task_data)
    expect_section_2_pulled
    expect_section_2_previous_section_called
    expect_section_1_gid_pulled
    expect_section_1_tasks_pulled
    expect_milestone_queried
  end

  # @return [void]
  def test_task_dependent_on_previous_section_last_milestone_true
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_true
    end

    # @sg-ignore Unresolved call to task_dependent_on_previous_section_last_milestone?
    assert(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  # @return [void]
  def mock_task_dependent_on_previous_section_last_milestone_false_no_previous_section
    memberships = [
      # @sg-ignore Unresolved call to section_2_gid
      { 'section' => { 'gid' => section_2_gid } },
    ]
    task_data = {
      'memberships' => memberships,
      'dependencies' => [
        # @sg-ignore Unresolved call to milestone_gid
        { 'gid' => milestone_gid },
      ],
    }
    # @sg-ignore Unresolved call to task
    expect_task_data_created(task, task_data)
    expect_section_2_pulled
    # @sg-ignore Unresolved call to sections
    sections.expects(:previous_section).with(section_2).returns(nil)
  end

  # @return [void]
  def test_task_dependent_on_previous_section_last_milestone_false_no_previous_section
    timelines = get_test_object do
      mock_task_dependent_on_previous_section_last_milestone_false_no_previous_section
    end

    # @sg-ignore Unresolved call to task_dependent_on_previous_section_last_milestone?
    refute(timelines.task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil))
  end

  # @return [void]
  def test_last_task_milestone_depends_on_this_task_no_memberships
    timelines = get_test_object do
      # @sg-ignore Unresolved call to task
      task.expects(:memberships).returns([])
    end

    # @sg-ignore Unresolved call to last_task_milestone_depends_on_this_task?
    assert(timelines.last_task_milestone_depends_on_this_task?(task))
  end

  # @param dependents [Object]
  # @param task [Object]
  # @return [void]
  def expect_all_dependent_tasks_pulled(task, dependents)
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:all_dependent_tasks).with(task).returns(dependents)
  end

  # @return [void]
  # @param memberships [Object]
  # @param task [Object]
  def expect_memberships_pulled(task, memberships)
    task.expects(:memberships).returns(memberships)
  end

  # @return [void]
  # @param tasks [Object]
  def expect_tasks_by_section_gid_pulled(tasks)
    # @sg-ignore Unresolved call to sections
    sections.expects(:tasks_by_section_gid)
      .with(section_1_gid, extra_fields: ['resource_subtype'])
      .returns(tasks)
  end

  # @return [void]
  def expect_milestone_details_pulled
    # @sg-ignore Unresolved call to milestone
    milestone.expects(:resource_subtype).returns('milestone')
    # @sg-ignore Unresolved call to milestone
    milestone.expects(:gid).returns(milestone_gid).at_least(1)
  end

  # @return [void]
  def expect_task_gid_pulled
    # @sg-ignore Unresolved call to task
    task.expects(:gid).returns(task_gid)
  end

  # @return [void]
  def test_last_task_milestone_depends_on_this_task_false
    timelines = get_test_object do
      # @sg-ignore Unresolved call to task
      expect_all_dependent_tasks_pulled(task, [])
      memberships = [
        {
          'section' => {
            # @sg-ignore Unresolved call to section_1_gid
            'gid' => section_1_gid,
          },
        },
      ]
      # @sg-ignore Unresolved call to task
      expect_memberships_pulled(task, memberships)
      # @sg-ignore Unresolved call to milestone
      expect_tasks_by_section_gid_pulled([milestone])
      expect_milestone_details_pulled
      expect_task_gid_pulled
    end

    # @sg-ignore Unresolved call to last_task_milestone_depends_on_this_task?
    refute(timelines.last_task_milestone_depends_on_this_task?(task))
  end

  # @return [void]
  def test_last_task_milestone_depends_on_this_task_no_milestone
    timelines = get_test_object do
      # expect_all_dependent_tasks_pulled(task, [])
      memberships = [
        {
          'section' => {
            # @sg-ignore Unresolved call to section_1_gid
            'gid' => section_1_gid,
          },
        },
      ]
      # @sg-ignore Unresolved call to task
      expect_memberships_pulled(task, memberships)
      expect_tasks_by_section_gid_pulled([])
    end

    # @sg-ignore Unresolved call to last_task_milestone_depends_on_this_task?
    refute(timelines.last_task_milestone_depends_on_this_task?(task))
  end

  # @return [void]
  def test_last_task_milestone_depends_on_this_task_is_last_milestone
    timelines = get_test_object do
      # expect_all_dependent_tasks_pulled(milestone, [])
      memberships = [
        {
          'section' => {
            # @sg-ignore Unresolved call to section_1_gid
            'gid' => section_1_gid,
          },
        },
      ]
      # @sg-ignore Unresolved call to milestone
      expect_memberships_pulled(milestone, memberships)
      # @sg-ignore Unresolved call to milestone
      expect_tasks_by_section_gid_pulled([milestone])
      expect_milestone_details_pulled
    end

    # @sg-ignore Unresolved call to last_task_milestone_depends_on_this_task?
    assert(timelines.last_task_milestone_depends_on_this_task?(milestone))
  end

  # @return [void]
  # @param projects [Object]
  def export_portfolio_projects_pulled(projects)
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:default_workspace).returns(default_workspace)
    # @sg-ignore Unresolved call to default_workspace
    default_workspace.expects(:name).returns(default_workspace_name)
    # @sg-ignore Unresolved call to portfolios
    portfolios.expects(:projects_in_portfolio).with(default_workspace_name,
                                                    portfolio_name).returns(projects)
  end

  # @return [void]
  def test_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio_no_projects
    timelines = get_test_object do
      # expect_all_dependent_tasks_pulled(milestone, [])
      memberships = [
        {
          'section' => {
            # @sg-ignore Unresolved call to section_1_gid
            'gid' => section_1_gid,
          },
          'project' => {
            # @sg-ignore Unresolved call to project_a_gid
            'gid' => project_a_gid,
          },
        },
      ]
      # @sg-ignore Unresolved call to milestone
      expect_memberships_pulled(milestone, memberships)
      # @sg-ignore Unresolved call to milestone
      expect_tasks_by_section_gid_pulled([milestone])
      expect_milestone_details_pulled
      # @sg-ignore Unresolved call to project_a
      export_portfolio_projects_pulled([project_a])
      # @sg-ignore Unresolved call to project_a
      project_a.expects(:gid).returns(project_a_gid)
    end

    # @sg-ignore Unresolved call to last_task_milestone_depends_on_this_task?
    assert(timelines.last_task_milestone_depends_on_this_task?(milestone,
                                                               limit_to_portfolio_name: portfolio_name))
  end

  # @return [void]
  def mock_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio
    memberships = [
      {
        'section' => {
          # @sg-ignore Unresolved call to section_1_gid
          'gid' => section_1_gid,
        },
        'project' => {
          # @sg-ignore Unresolved call to project_a_gid
          'gid' => project_a_gid,
        },
      },
    ]
    # @sg-ignore Unresolved call to milestone
    expect_memberships_pulled(milestone, memberships)
    export_portfolio_projects_pulled([])
  end

  # @return [void]
  def test_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio
    timelines = get_test_object do
      mock_last_task_milestone_depends_on_this_task_is_last_milestone_limited_to_portfolio
    end

    # @sg-ignore Unresolved call to last_task_milestone_depends_on_this_task?
    assert(timelines.last_task_milestone_depends_on_this_task?(milestone,
                                                               limit_to_portfolio_name: portfolio_name))
  end

  # @return [void]
  def test_init
    timelines = get_test_object

    refute_nil(timelines)
  end

  # @return [void]
  def test_any_milestone_depends_on_this_task_false
    timelines = get_test_object do
      # @sg-ignore Unresolved call to project_a_gid
      memberships = [{ 'project' => { 'gid' => project_a_gid } }]
      # @sg-ignore Unresolved call to task
      expect_memberships_pulled(task, memberships)
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:all_dependent_tasks)
        .with(task, extra_task_fields: ['resource_subtype', 'memberships.project.gid'])
        .returns([])
    end

    # @sg-ignore Unresolved call to any_milestone_depends_on_this_task?
    refute(timelines.any_milestone_depends_on_this_task?(task))
  end

  # @return [void]
  def test_any_milestone_depends_on_this_task_true
    timelines = get_test_object do
      # @sg-ignore Unresolved call to project_a_gid
      memberships = [{ 'project' => { 'gid' => project_a_gid } }]
      # @sg-ignore Unresolved call to task
      expect_memberships_pulled(task, memberships)
      # @sg-ignore Unresolved call to project_a
      export_portfolio_projects_pulled([project_a])
      # @sg-ignore Unresolved call to project_a
      project_a.expects(:gid).returns(project_a_gid)
      dependent_milestone = mock('dependent_milestone')
      dependent_milestone.expects(:resource_subtype).returns('milestone')
      dependent_milestone.expects(:memberships)
        # @sg-ignore Unresolved call to project_a_gid
        .returns([{ 'project' => { 'gid' => project_a_gid } }])
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:all_dependent_tasks)
        .with(task, extra_task_fields: ['resource_subtype', 'memberships.project.gid'])
        .returns([dependent_milestone])
    end

    # @sg-ignore Unresolved call to any_milestone_depends_on_this_task?
    assert(timelines.any_milestone_depends_on_this_task?(task, limit_to_portfolio_name: portfolio_name))
  end

  # @return [void]
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
