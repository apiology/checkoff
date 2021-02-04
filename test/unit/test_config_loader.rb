# frozen_string_literal: true

require_relative 'class_test'

# Test the Checkoff::ConfigLoader class
class TestConfigLoader < Minitest::Test
  let_mock :yaml_results

  def test_defers_to_yaml
    Checkoff::ConfigLoader.stub :load_yaml_file, yaml_results do
      result = Checkoff::ConfigLoader.load(:foo)
      assert_equal(result, yaml_results)
    end
  end
end
