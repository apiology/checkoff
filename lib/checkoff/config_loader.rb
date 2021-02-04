# frozen_string_literal: true

require 'yaml'
require 'active_support/core_ext/hash'

module Checkoff
  # Load configuration file
  class ConfigLoader
    def self.load_yaml_file(sym)
      file = "#{sym}.yml"
      YAML.load_file(File.expand_path("~/.#{file}"))
          .with_indifferent_access
    end

    def self.load(sym)
      load_yaml_file(sym)
    end
  end
end
