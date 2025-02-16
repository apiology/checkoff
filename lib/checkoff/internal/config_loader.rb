# typed: true
# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'

module Checkoff
  module Internal
    # Use the provided config from a YAML file, and fall back to env
    # variable if it's not populated for a key'
    class EnvFallbackConfigLoader
      # @param config [Hash<Symbol, Object>]
      # @param sym [Symbol]
      # @param yaml_filename [String]
      def initialize(config, sym, yaml_filename)
        @config = config
        @envvar_prefix = sym.upcase
        @yaml_filename = yaml_filename
      end

      # @param key [Symbol]
      # @return [Object]
      def [](key)
        config_value = @config[key]
        return config_value unless config_value.nil?

        # @sg-ignore
        ENV.fetch(envvar_name(key), nil)
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
        # @return [EnvFallbackConfigLoader,Hash]
        def load(sym)
          yaml_result = load_yaml_file(sym)
          EnvFallbackConfigLoader.new(yaml_result, sym, yaml_filename(sym))
        end

        private

        # @param sym [Symbol]
        # @return [Hash<[String, Symbol], Object>]
        def load_yaml_file(sym)
          filename = yaml_filename(sym)
          return {} unless File.exist?(filename)

          # @sg-ignore
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
