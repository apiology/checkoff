# typed: false
# frozen_string_literal: true
# typed: ignore

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with mv subcommand
class TestCLIMv < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks

  # @return [void]
  def expect_workspaces_created
    # @sg-ignore Unresolved call to workspaces
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  # @return [void]
  def expect_config_loaded
    # @sg-ignore Unresolved call to config
    Checkoff::Internal::ConfigLoader.expects(:load).returns(config).at_least(0)
  end

  # @return [void]
  def expect_sections_created
    # @sg-ignore Unresolved call to sections
    Checkoff::Sections.expects(:new).returns(sections).at_least(0)
  end

  # @return [void]
  def expect_tasks_created
    # @sg-ignore Unresolved call to tasks
    Checkoff::Tasks.expects(:new).returns(tasks).at_least(0)
  end

  # @return [void]
  def set_mocks
    @mocks = {
      # @sg-ignore Unresolved call to config
      config:,
      # @sg-ignore Unresolved call to workspaces
      workspaces:,
      # @sg-ignore Unresolved call to sections
      sections:,
      # @sg-ignore Unresolved call to tasks
      tasks:,
      stderr: $stderr,
      stdout: $stdout,
    }
  end

  # @return [void]
  def get_test_object(&_twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks
    Checkoff::CheckoffGLIApp
  end

  let_mock :mv_subcommand

  # @return [void]
  def mock_mv_original_use_case
    Checkoff::MvSubcommand.expects(:new).with(from_workspace_arg: 'from_workspace_name',
                                              from_project_arg: ':my_tasks',
                                              from_section_arg: 'Recently assigned',
                                              to_workspace_arg: :source_workspace,
                                              to_project_arg: :source_project,
                                              # @sg-ignore Unresolved call to mv_subcommand
                                              to_section_arg: 'Later').returns(mv_subcommand)
    # @sg-ignore Unresolved call to mv_subcommand
    mv_subcommand.expects(:run)
  end

  # @return [void]
  def test_mv_original_use_case
    cli = get_test_object do
      mock_mv_original_use_case
    end
    # @sg-ignore Unresolved call to run
    cli.run(['mv',
             '--from-workspace=from_workspace_name',
             '--from-project=:my_tasks',
             '--from-section=Recently assigned',
             '--to_section=Later'])
  end
end
