# typed: false
# frozen_string_literal: true

require_relative '../class_test'

# Test the Checkoff::Internal::ConfigLoader class
class TestConfigLoader < Minitest::Test
  # @return [void]
  def mock_yaml_loaded
    filename = File.expand_path('~/.foo.yml')
    File.expects(:exist?).with(filename).returns(true)
    YAML.expects(:load_file).returns({ 'bar' => 'yaml_value' })
  end

  # @return [void]
  def test_requests_from_env_variable_neither_populated
    mock_yaml_loaded

    config_hash = Checkoff::Internal::ConfigLoader.load(:foo)

    # Ruby 4.1 makes ENV shareable, so Mocha can no longer stub it
    with_env('FOO__NO_KEY_FOUND' => nil) do
      assert_nil(config_hash[:no_key_found])
      assert_raises(KeyError) do
        config_hash.fetch(:no_key_found)
      end
    end
  end

  # @return [void]
  def test_requests_from_env_variable_if_yaml_not_populated
    mock_yaml_loaded

    config_hash = Checkoff::Internal::ConfigLoader.load(:foo)

    with_env('FOO__ENV_ONLY_KEY' => '123') do
      assert_equal('123', config_hash[:env_only_key])
      assert_equal('123', config_hash.fetch(:env_only_key))
    end
  end

  # Sets environment variables for the block, then restores them
  #
  # @param vars [Hash{String => String, nil}] nil unsets the variable
  # @return [void]
  def with_env(vars)
    old = vars.to_h { |name, _| [name, ENV.fetch(name, nil)] }
    vars.each { |name, value| ENV[name] = value }
    yield
  ensure
    old&.each { |name, value| ENV[name] = value }
  end

  # @return [void]
  def test_defers_to_yaml
    mock_yaml_loaded

    config_hash = Checkoff::Internal::ConfigLoader.load(:foo)

    assert_equal('yaml_value', config_hash[:bar])
    assert_equal('yaml_value', config_hash.fetch(:bar))
  end
end
