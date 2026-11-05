# typed: false
# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'

# Test the Checkoff::CLI class with the help option
class TestCLIHelp < Minitest::Test
  # GLI binds its help command to the process's standard output when
  # the app is defined, so capture at the file-descriptor level.
  #
  # @return [void]
  def test_run_with_help_arg
    exit_code = nil
    out, _err = capture_subprocess_io do
      exit_code = Checkoff::CheckoffGLIApp.run(['--help'])
    end

    assert_equal(0, exit_code)
    assert_match(/Command-line client for Asana/, out)
  end
end
