# typed: false
# frozen_string_literal: true

require 'tempfile'
require_relative '../class_test'

# Test the Checkoff::Internal::ConfigLoader class
class TestConfigLoader < Minitest::Test
  # @param env [Hash{String => String}]
  # @return [Checkoff::Internal::EnvFallbackConfigLoader]
  def load_config(env: {})
    Tempfile.create(['foo', '.yml']) do |file|
      file.write({ 'bar' => 'yaml_value' }.to_yaml)
      file.close
      Checkoff::Internal::ConfigLoader.load(:foo, filename: file.path, env:)
    end
  end

  # @return [void]
  def test_requests_from_env_variable_neither_populated
    config_hash = load_config

    assert_nil(config_hash[:no_key_found])
    assert_raises(KeyError) do
      config_hash.fetch(:no_key_found)
    end
  end

  # @return [void]
  def test_requests_from_env_variable_if_yaml_not_populated
    config_hash = load_config(env: { 'FOO__ENV_ONLY_KEY' => '123' })

    assert_equal('123', config_hash[:env_only_key])
    assert_equal('123', config_hash.fetch(:env_only_key))
  end

  # @return [void]
  def test_defers_to_yaml
    config_hash = load_config

    assert_equal('yaml_value', config_hash[:bar])
    assert_equal('yaml_value', config_hash.fetch(:bar))
  end
end
