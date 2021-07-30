# frozen_string_literal: true

require_relative 'class_test'
require 'checkoff/cli'
require_relative 'base_cli'

# Test the Checkoff::CLI class with the help option
class TestCLIHelp < BaseCLI
  def test_run_with_help_arg
    asana_my_tasks = get_test_object do
      @mocks[:stdout].expects(:puts).at_least(1)
    end
    assert_equal(0, asana_my_tasks.run(['--help']))
  end
end
