# typed: false
# frozen_string_literal: true
# typed: ignore

require 'checkoff/cli'
require_relative 'class_test'

# Test the Checkoff::MvSubcommand class used in CLI processing
class TestMvSubcommand < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :projects, :sections,
                 :logger)

  let_mock :to_project, :to_project_gid,
           :to_section, :to_section_gid,
           :task_a, :task_a_name

  attr_reader :from_workspace_arg, :from_project_arg, :from_section_arg,
              :to_workspace_arg, :to_project_arg, :to_section_arg,
              :from_workspace_name, :from_project_name, :from_section_name,
              :to_workspace_name, :to_project_name, :to_section_name

  def argument_to_name(arg)
    if arg.start_with? ':'
      arg[1..].to_sym
    else
      arg
    end
  end

  def expect_project_pulled(workspace_name, project_name, project)
    projects.expects(:project_or_raise)
      .with(workspace_name, project_name)
      .returns(project)
  end

  def expect_section_pulled(workspace_name, project_name, section_name, section)
    sections.expects(:section_or_raise).with(workspace_name, project_name, section_name)
      .returns(section)
  end

  def expect_tasks_pulled(workspace_name, project_name, section_name, tasks)
    return if section_name == :all_sections # not implemented yet

    sections.expects(:tasks).with(workspace_name, project_name, section_name)
      .returns(tasks)
  end

  def expect_task_named(task, task_name)
    task.expects(:name).returns(task_name)
  end

  def expect_section_named(section, section_name)
    section.expects(:name).returns(section_name)
  end

  def expect_project_gid_pulled(project, project_gid)
    project.expects(:gid).returns(project_gid)
  end

  def expect_section_gid_pulled(section, section_gid)
    section.expects(:gid).returns(section_gid)
  end

  def expect_task_added_to_project(task, project_gid, section_gid)
    task.expects(:add_project).with(project: project_gid, section: section_gid)
  end

  def allow_logger_used
    logger.expects(:puts).at_least(0)
  end

  def set_initializer_arguments
    @mocks[:from_workspace_arg] = from_workspace_arg
    @mocks[:from_project_arg] = from_project_arg
    @mocks[:from_section_arg] = from_section_arg
    @mocks[:to_workspace_arg] = to_workspace_arg
    @mocks[:to_project_arg] = to_project_arg
    @mocks[:to_section_arg] = to_section_arg
  end

  def determine_to_workspace_name(from_workspace_arg, to_workspace_arg)
    if to_workspace_arg == :source_workspace
      from_workspace_arg
    else
      to_workspace_arg
    end
  end

  def determine_to_project_name(from_project_name, to_project_arg)
    if to_project_arg == :source_project
      from_project_name
    else
      to_project_arg
    end
  end

  def determine_to_section_name(from_section_name, to_section_arg)
    if to_section_arg == :source_section
      from_section_name
    else
      to_section_arg
    end
  end

  def expect_task_added_to_section(task, task_name)
    return if from_section_name == :all_sections # not implemented yet

    expect_task_named(task, task_name)
    expect_section_named(to_section, to_section_name)
    expect_project_gid_pulled(to_project, to_project_gid)
    expect_section_gid_pulled(to_section, to_section_gid)
    expect_task_added_to_project(task, to_project_gid, to_section_gid)
  end

  def set_names
    @from_workspace_name = from_workspace_arg
    @from_project_name = argument_to_name(from_project_arg)
    @from_section_name = from_section_arg
    @to_workspace_name = determine_to_workspace_name(from_workspace_arg, to_workspace_arg)
    @to_project_name = determine_to_project_name(from_project_name, to_project_arg)
    @to_section_name = determine_to_section_name(from_section_name, to_section_arg)
  end

  def expect_to_objects_pulled
    expect_project_pulled(to_workspace_name, to_project_name, to_project)
    expect_section_pulled(to_workspace_name, to_project_name, to_section_name, to_section)
  end

  def expect_run
    set_names
    set_initializer_arguments

    return if from_workspace_name != to_workspace_name # not implemented yet

    expect_to_objects_pulled
    expect_tasks_pulled(from_workspace_name, from_project_name, from_section_name, [task_a])
    expect_task_added_to_section(task_a, task_a_name)
    allow_logger_used
  end

  def mock_run_to_different_workspace
    @from_workspace_arg = 'My workspace'
    @from_project_arg = 'My project'
    @from_section_arg = 'My section'
    @to_workspace_arg = 'Some other workspace'
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  def test_run_to_different_workspace
    assert_raises(NotImplementedError) do
      get_test_object do
        mock_run_to_different_workspace
      end
    end
  end

  def mock_run_from_all_sections
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = :all_sections
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  def test_run_from_all_sections
    mv_subcommand = get_test_object do
      mock_run_from_all_sections
    end
    assert_raises(NotImplementedError) do
      mv_subcommand.run
    end
  end

  def mock_run_from_regular_project
    @from_workspace_arg = 'My workspace'
    @from_project_arg = 'My project'
    @from_section_arg = 'My section'
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  def test_run_from_regular_project
    mv_subcommand = get_test_object do
      mock_run_from_regular_project
    end
    mv_subcommand.run
  end

  def mock_run_to_same_section_different_project
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  def test_run_to_same_section_different_project
    mv_subcommand = get_test_object do
      mock_run_to_same_section_different_project
    end
    mv_subcommand.run
  end

  def mock_run_with_explicit_to_project
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = 'Later'

    expect_run
  end

  def test_run_with_explicit_to_project
    mv_subcommand = get_test_object do
      mock_run_with_explicit_to_project
    end
    mv_subcommand.run
  end

  def mock_run_from_my_tasks
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = :source_project
    @to_section_arg = 'Later'

    expect_run
  end

  def test_run_from_my_tasks
    mv_subcommand = get_test_object do
      mock_run_from_my_tasks
    end
    mv_subcommand.run
  end

  def mock_init_default_workspace_not_implemented
    @from_workspace_arg = :default_workspace
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = :source_project
    @to_section_arg = 'Later'

    set_initializer_arguments
  end

  def test_init_default_workspace_not_implemented
    assert_raises(NotImplementedError) do
      get_test_object do
        mock_init_default_workspace_not_implemented
      end
    end
  end

  def test_init
    mv_subcommand = get_test_object do
      @from_workspace_arg = 'My workspace'
      @from_project_arg = ':my_tasks'
      @from_section_arg = 'Recently assigned'
      @to_workspace_arg = :source_workspace
      @to_project_arg = :source_project
      @to_section_arg = 'Later'

      set_initializer_arguments
    end

    refute_nil mv_subcommand
  end

  def class_under_test
    ::Checkoff::MvSubcommand
  end
end
