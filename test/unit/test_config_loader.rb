# frozen_string_literal: true

require_relative 'class_test'

# Test the Checkoff::ConfigLoader class
class TestConfigLoader < Minitest::Test
  let_mock :yaml_results

  def mock_load_yaml_file_called
    Checkoff::ConfigLoader.expects(:load_yaml_file).with(:foo).returns(yaml_results)
  end

  def mock_yaml_loaded
    mock_load_yaml_file_called
    yaml_results.expects(:[]).with(:env_only_key).returns(nil).at_least(0)
    yaml_results.expects(:[]).with(:no_key_found).returns(nil).at_least(0)
    yaml_results.expects(:[]).with(:bar).returns('yaml_value').at_least(0)
  end

  def test_requests_from_env_variable_neither_populated
    mock_yaml_loaded

    config_hash = Checkoff::ConfigLoader.load(:foo)

    ENV.expects(:[]).with('FOO__NO_KEY_FOUND').returns(nil).at_least(2)

    assert_nil(config_hash[:no_key_found])
    assert_raises(KeyError) do
      config_hash.fetch(:no_key_found)
    end
  end

  def test_requests_from_env_variable_if_yaml_not_populated
    mock_yaml_loaded

    config_hash = Checkoff::ConfigLoader.load(:foo)

    ENV.expects(:[]).with('FOO__ENV_ONLY_KEY').returns('123').at_least(2)
    assert_equal('123', config_hash[:env_only_key])
    assert_equal('123', config_hash.fetch(:env_only_key))
  end

  def test_defers_to_yaml
    mock_yaml_loaded

    config_hash = Checkoff::ConfigLoader.load(:foo)

    assert_equal('yaml_value', config_hash[:bar])
    assert_equal('yaml_value', config_hash.fetch(:bar))
  end
end
