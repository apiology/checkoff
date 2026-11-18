# typed: true
# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'

module Checkoff
  module Internal
    # Use the provided config from a YAML file, and fall back to env
    # variable if it's not populated for a key'
    class EnvFallbackConfigLoader
      # @param config [Hash{Symbol => undefined}]
      # @param sym [Symbol]
      # @param yaml_filename [String]
      # @param env [Hash{String => String}, nil] read instead of ENV;
      #   ENV itself is never stored, so the loader stays marshalable
      def initialize(config, sym, yaml_filename, env: nil)
        @config = config
        @envvar_prefix = sym.upcase
        @yaml_filename = yaml_filename
        @env = env
      end

      # @param key [Symbol]
      # @return [Object, nil]
      def [](key)
        config_value = @config[key]
        return config_value unless config_value.nil?

        (@env || ENV).fetch(envvar_name(key), nil)
      end

      # @param key [Symbol]
      # @return [Object]
      def fetch(key)
        out = self[key]
        return out unless out.nil?

        raise KeyError,
              "Please configure either the #{key} key in #{@yaml_filename} or set #{envvar_name(key)}"
      end

      private

      # @param key [Symbol]
      # @return [String]
      def envvar_name(key)
        "#{@envvar_prefix}__#{key.upcase}"
      end
    end

    # Load configuration file
    class ConfigLoader
      class << self
        # @param sym [Symbol]
        # @param filename [String]
        # @param env [Hash{String => String}, nil] read instead of ENV
        #
        # @return [EnvFallbackConfigLoader]
        def load(sym, filename: yaml_filename(sym), env: nil)
          yaml_result = load_yaml_file(filename)
          EnvFallbackConfigLoader.new(yaml_result, sym, filename, env:)
        end

        private

        # @param filename [String]
        # @return [Hash{Symbol => undefined}]
        def load_yaml_file(filename)
          return {} unless File.exist?(filename)

          YAML.load_file(filename).with_indifferent_access
        end

        # @param sym [Symbol]
        # @return [String]
        def yaml_filename(sym)
          file = "#{sym}.yml"
          File.expand_path("~/.#{file}")
        end
      end
    end
  end
end
