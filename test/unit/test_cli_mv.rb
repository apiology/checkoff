# frozen_string_literal: true

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with mv subcommand
class TestCLIMv < Minitest::Test
  let_mock :config, :workspaces, :sections, :tasks

  def expect_workspaces_created
    Checkoff::Workspaces.expects(:new).returns(workspaces).at_least(0)
  end

  def expect_config_loaded
    Checkoff::ConfigLoader.expects(:load).returns(config).at_least(0)
  end

  def expect_sections_created
    Checkoff::Sections.expects(:new).returns(sections).at_least(0)
  end

  def expect_tasks_created
    Checkoff::Tasks.expects(:new).returns(tasks).at_least(0)
  end

  def set_mocks
    @mocks = {
      config: config,
      workspaces: workspaces,
      sections: sections,
      tasks: tasks,
      stderr: $stderr,
      stdout: $stdout,
    }
  end

  def get_test_object(&twiddle_mocks)
    set_mocks
    expect_workspaces_created
    expect_config_loaded
    expect_sections_created
    expect_tasks_created

    yield @mocks if twiddle_mocks
    Checkoff::CheckoffGLIApp
  end

  let_mock :mv_subcommand

  def mock_mv_original_use_case
    Checkoff::MvSubcommand.expects(:new).with(from_workspace: 'from_workspace_name',
                                              from_project: ':my_tasks',
                                              from_section: 'Recently assigned',
                                              to_workspace: :source_workspace,
                                              to_project: :source_project,
                                              to_section: 'Later').returns(mv_subcommand)
    mv_subcommand.expects(:run)
  end

  def test_mv_original_use_case
    cli = get_test_object do
      mock_mv_original_use_case
    end
    cli.run(['mv',
             '--from-workspace=from_workspace_name',
             '--from-project=:my_tasks',
             '--from-section=Recently assigned',
             '--to_section=Later'])
  end
end
