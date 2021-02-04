# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'

module Checkoff
  class EnvFallbackConfigLoader
    def initialize(config, sym, yaml_filename)
      @config = config
      @envvar_prefix = sym.upcase
      @yaml_filename = yaml_filename
    end

    def envvar_name(key)
      "#{@envvar_prefix}__#{key.upcase}"
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
  end

  # Load configuration file
  class ConfigLoader
    def self.yaml_filename(sym)
      file = "#{sym}.yml"
      File.expand_path("~/.#{file}")
    end

    def self.load_yaml_file(sym)
      filename = yaml_filename(sym)
      return {} unless File.exist?(filename)

      YAML.load_file(filename).with_indifferent_access
    end

    def self.load(sym)
      yaml_result = load_yaml_file(sym)
      EnvFallbackConfigLoader.new(yaml_result, sym, yaml_filename(sym))
    end
  end
end
