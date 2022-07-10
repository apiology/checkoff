# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'

module Checkoff
  module Internal
    # Use the provided config from a YAML file, and fall back to env
    # variable if it's not populated for a key'
    class EnvFallbackConfigLoader
      def initialize(config, sym, yaml_filename)
        @config = config
        @envvar_prefix = sym.upcase
        @yaml_filename = yaml_filename
      end

      def [](key)
        config_value = @config[key]
        return config_value unless config_value.nil?

        ENV[envvar_name(key)]
      end

      def fetch(key)
        out = self[key]
        return out unless out.nil?

        raise KeyError,
              "Please configure either the #{key} key in #{@yaml_filename} or set #{envvar_name(key)}"
      end

      private

      def envvar_name(key)
        "#{@envvar_prefix}__#{key.upcase}"
      end
    end

    # Load configuration file
    class ConfigLoader
      class << self
        def load(sym)
          yaml_result = load_yaml_file(sym)
          EnvFallbackConfigLoader.new(yaml_result, sym, yaml_filename(sym))
        end

        private

        def load_yaml_file(sym)
          filename = yaml_filename(sym)
          return {} unless File.exist?(filename)

          YAML.load_file(filename).with_indifferent_access
        end

        def yaml_filename(sym)
          file = "#{sym}.yml"
          File.expand_path("~/.#{file}")
        end
      end
    end
  end
end
