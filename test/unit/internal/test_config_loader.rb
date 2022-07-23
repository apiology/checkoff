# frozen_string_literal: true

require_relative '../class_test'

# Test the Checkoff::Internal::ConfigLoader class
class TestConfigLoader < Minitest::Test
  def mock_yaml_loaded
    filename = File.expand_path('~/.foo.yml')
    File.expects(:exist?).with(filename).returns(true)
    YAML.expects(:load_file).returns({ 'bar' => 'yaml_value' })
  end

  def test_requests_from_env_variable_neither_populated
    mock_yaml_loaded

    config_hash = Checkoff::Internal::ConfigLoader.load(:foo)

    ENV.expects(:[]).with('FOO__NO_KEY_FOUND').returns(nil).at_least(2)

    assert_nil(config_hash[:no_key_found])
    assert_raises(KeyError) do
      config_hash.fetch(:no_key_found)
    end
  end

  def test_requests_from_env_variable_if_yaml_not_populated
    mock_yaml_loaded

    config_hash = Checkoff::Internal::ConfigLoader.load(:foo)

    ENV.expects(:[]).with('FOO__ENV_ONLY_KEY').returns('123').at_least(2)
    assert_equal('123', config_hash[:env_only_key])
    assert_equal('123', config_hash.fetch(:env_only_key))
  end

  def test_defers_to_yaml
    mock_yaml_loaded

    config_hash = Checkoff::Internal::ConfigLoader.load(:foo)

    assert_equal('yaml_value', config_hash[:bar])
    assert_equal('yaml_value', config_hash.fetch(:bar))
  end
end
