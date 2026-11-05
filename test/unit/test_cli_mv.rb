# typed: false
# frozen_string_literal: true
# typed: ignore

require 'checkoff/cli'
require_relative 'test_helper'

# Test the Checkoff::CLI class with mv subcommand
class TestCLIMv < Minitest::Test
  # @return [Hash]
  attr_reader :mocks

  # @return [void]
  def set_mocks
    @mocks = {
      stderr: $stderr,
      stdout: $stdout,
    }
  end

  # @return [Class<Checkoff::CheckoffGLIApp>]
  def get_test_object(&_twiddle_mocks)
    set_mocks

    yield @mocks
    Checkoff::CheckoffGLIApp
  end

  typed_mock :mv_subcommand, Checkoff::MvSubcommand

  # @return [void]
  def mock_mv_original_use_case
    Checkoff::MvSubcommand.expects(:new).with(from_workspace_arg: 'from_workspace_name',
                                              from_project_arg: ':my_tasks',
                                              from_section_arg: 'Recently assigned',
                                              to_workspace_arg: :source_workspace,
                                              to_project_arg: :source_project,
                                              to_section_arg: 'Later').returns(mv_subcommand)
    mv_subcommand.expects(:run)
  end

  # @return [void]
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
