# typed: false
# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class with the help option
class TestCLIHelp < Minitest::Test
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
  def get_test_object(&twiddle_mocks)
    set_mocks

    yield @mocks if twiddle_mocks
    Checkoff::CheckoffGLIApp
  end

  # @return [void]
  def test_run_with_help_arg
    cli = get_test_object do
      mocks[:stdout].expects(:puts).at_least(1)
    end

    assert_equal(0, cli.run(['--help']))
  end
end
