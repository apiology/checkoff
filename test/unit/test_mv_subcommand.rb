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

  # @return [Object]
  attr_reader :from_workspace_arg, :from_project_arg, :from_section_arg,
              :to_workspace_arg, :to_project_arg, :to_section_arg,
              :from_workspace_name, :from_project_name, :from_section_name,
              :to_workspace_name, :to_project_name, :to_section_name

  # @return [Object]
  # @param arg [Object]
  def argument_to_name(arg)
    # @sg-ignore Unresolved call to start_with?
    if arg.start_with? ':'
      # @sg-ignore Unresolved call to []
      arg[1..].to_sym
    else
      arg
    end
  end

  # @return [void]
  # @param project [Object]
  # @param project_name [Object]
  # @param workspace_name [Object]
  def expect_project_pulled(workspace_name, project_name, project)
    # @sg-ignore Unresolved call to projects
    projects.expects(:project_or_raise)
      .with(workspace_name, project_name)
      .returns(project)
  end

  # @return [void]
  # @param project_name [Object]
  # @param workspace_name [Object]
  # @param section [Object]
  # @param section_name [Object]
  def expect_section_pulled(workspace_name, project_name, section_name, section)
    # @sg-ignore Unresolved call to sections
    sections.expects(:section_or_raise).with(workspace_name, project_name, section_name)
      .returns(section)
  end

  # @return [void]
  # @param workspace_name [Object]
  # @param tasks [Object]
  # @param section_name [Object]
  # @param project_name [Object]
  def expect_tasks_pulled(workspace_name, project_name, section_name, tasks)
    return if section_name == :all_sections # not implemented yet

    # @sg-ignore Unresolved call to sections
    sections.expects(:tasks).with(workspace_name, project_name, section_name)
      .returns(tasks)
  end

  # @return [void]
  # @param task [Object]
  # @param task_name [Object]
  def expect_task_named(task, task_name)
    task.expects(:name).returns(task_name)
  end

  # @return [void]
  # @param section_name [Object]
  # @param section [Object]
  def expect_section_named(section, section_name)
    section.expects(:name).returns(section_name)
  end

  # @return [void]
  # @param project_gid [Object]
  # @param project [Object]
  def expect_project_gid_pulled(project, project_gid)
    project.expects(:gid).returns(project_gid)
  end

  # @return [void]
  # @param section [Object]
  # @param section_gid [Object]
  def expect_section_gid_pulled(section, section_gid)
    section.expects(:gid).returns(section_gid)
  end

  # @return [void]
  # @param section_gid [Object]
  # @param project_gid [Object]
  # @param task [Object]
  def expect_task_added_to_project(task, project_gid, section_gid)
    task.expects(:add_project).with(project: project_gid, section: section_gid)
  end

  # @return [void]
  def allow_logger_used
    # @sg-ignore Unresolved call to logger
    logger.expects(:puts).at_least(0)
  end

  # @return [void]
  def set_initializer_arguments
    # @sg-ignore Unresolved call to @mocks
    @mocks[:from_workspace_arg] = from_workspace_arg
    # @sg-ignore Unresolved call to @mocks
    @mocks[:from_project_arg] = from_project_arg
    # @sg-ignore Unresolved call to @mocks
    @mocks[:from_section_arg] = from_section_arg
    # @sg-ignore Unresolved call to @mocks
    @mocks[:to_workspace_arg] = to_workspace_arg
    # @sg-ignore Unresolved call to @mocks
    @mocks[:to_project_arg] = to_project_arg
    # @sg-ignore Unresolved call to @mocks
    @mocks[:to_section_arg] = to_section_arg
  end

  # @return [void]
  # @param from_workspace_arg [Object]
  # @param to_workspace_arg [Object]
  def determine_to_workspace_name(from_workspace_arg, to_workspace_arg)
    if to_workspace_arg == :source_workspace
      from_workspace_arg
    else
      to_workspace_arg
    end
  end

  # @return [void]
  # @param to_project_arg [Object]
  # @param from_project_name [Object]
  def determine_to_project_name(from_project_name, to_project_arg)
    if to_project_arg == :source_project
      from_project_name
    else
      to_project_arg
    end
  end

  # @return [void]
  # @param from_section_name [Object]
  # @param to_section_arg [Object]
  def determine_to_section_name(from_section_name, to_section_arg)
    if to_section_arg == :source_section
      from_section_name
    else
      to_section_arg
    end
  end

  # @return [void]
  # @param task_name [Object]
  # @param task [Object]
  def expect_task_added_to_section(task, task_name)
    return if from_section_name == :all_sections # not implemented yet

    expect_task_named(task, task_name)
    # @sg-ignore Unresolved call to to_section
    expect_section_named(to_section, to_section_name)
    # @sg-ignore Unresolved call to to_project
    # @sg-ignore Unresolved call to to_project_gid
    expect_project_gid_pulled(to_project, to_project_gid)
    # @sg-ignore Unresolved call to to_section
    # @sg-ignore Unresolved call to to_section_gid
    expect_section_gid_pulled(to_section, to_section_gid)
    # @sg-ignore Unresolved call to to_project_gid
    # @sg-ignore Unresolved call to to_section_gid
    expect_task_added_to_project(task, to_project_gid, to_section_gid)
  end

  # @return [void]
  def set_names
    @from_workspace_name = from_workspace_arg
    @from_project_name = argument_to_name(from_project_arg)
    @from_section_name = from_section_arg
    @to_workspace_name = determine_to_workspace_name(from_workspace_arg, to_workspace_arg)
    @to_project_name = determine_to_project_name(from_project_name, to_project_arg)
    @to_section_name = determine_to_section_name(from_section_name, to_section_arg)
  end

  # @return [void]
  def expect_to_objects_pulled
    # @sg-ignore Unresolved call to to_project
    expect_project_pulled(to_workspace_name, to_project_name, to_project)
    # @sg-ignore Unresolved call to to_section
    expect_section_pulled(to_workspace_name, to_project_name, to_section_name, to_section)
  end

  # @return [void]
  def expect_run
    set_names
    set_initializer_arguments

    return if from_workspace_name != to_workspace_name # not implemented yet

    expect_to_objects_pulled
    # @sg-ignore Unresolved call to task_a
    expect_tasks_pulled(from_workspace_name, from_project_name, from_section_name, [task_a])
    # @sg-ignore Unresolved call to task_a
    # @sg-ignore Unresolved call to task_a_name
    expect_task_added_to_section(task_a, task_a_name)
    allow_logger_used
  end

  # @return [void]
  def mock_run_to_different_workspace
    @from_workspace_arg = 'My workspace'
    @from_project_arg = 'My project'
    @from_section_arg = 'My section'
    @to_workspace_arg = 'Some other workspace'
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  # @return [void]
  def test_run_to_different_workspace
    assert_raises(NotImplementedError) do
      get_test_object do
        mock_run_to_different_workspace
      end
    end
  end

  # @return [void]
  def mock_run_from_all_sections
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = :all_sections
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  # @return [void]
  def test_run_from_all_sections
    mv_subcommand = get_test_object do
      mock_run_from_all_sections
    end
    assert_raises(NotImplementedError) do
      # @sg-ignore Unresolved call to run
      mv_subcommand.run
    end
  end

  # @return [void]
  def mock_run_from_regular_project
    @from_workspace_arg = 'My workspace'
    @from_project_arg = 'My project'
    @from_section_arg = 'My section'
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  # @return [void]
  def test_run_from_regular_project
    mv_subcommand = get_test_object do
      mock_run_from_regular_project
    end
    # @sg-ignore Unresolved call to run
    mv_subcommand.run
  end

  # @return [void]
  def mock_run_to_same_section_different_project
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = :source_section

    expect_run
  end

  # @return [void]
  def test_run_to_same_section_different_project
    mv_subcommand = get_test_object do
      mock_run_to_same_section_different_project
    end
    # @sg-ignore Unresolved call to run
    mv_subcommand.run
  end

  # @return [void]
  def mock_run_with_explicit_to_project
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = 'Some other project'
    @to_section_arg = 'Later'

    expect_run
  end

  # @return [void]
  def test_run_with_explicit_to_project
    mv_subcommand = get_test_object do
      mock_run_with_explicit_to_project
    end
    # @sg-ignore Unresolved call to run
    mv_subcommand.run
  end

  # @return [void]
  def mock_run_from_my_tasks
    @from_workspace_arg = 'My workspace'
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = :source_project
    @to_section_arg = 'Later'

    expect_run
  end

  # @return [void]
  def test_run_from_my_tasks
    mv_subcommand = get_test_object do
      mock_run_from_my_tasks
    end
    # @sg-ignore Unresolved call to run
    mv_subcommand.run
  end

  # @return [void]
  def mock_init_default_workspace_not_implemented
    @from_workspace_arg = :default_workspace
    @from_project_arg = ':my_tasks'
    @from_section_arg = 'Recently assigned'
    @to_workspace_arg = :source_workspace
    @to_project_arg = :source_project
    @to_section_arg = 'Later'

    set_initializer_arguments
  end

  # @return [void]
  def test_init_default_workspace_not_implemented
    assert_raises(NotImplementedError) do
      get_test_object do
        mock_init_default_workspace_not_implemented
      end
    end
  end

  # @return [void]
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

  # @return [void]
  def class_under_test
    ::Checkoff::MvSubcommand
  end
end
