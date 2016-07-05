require 'yaml'
require 'active_support/core_ext/hash'

module Checkoff
  # Load configuration file
  class ConfigLoader
    def self.load(sym)
      file = "#{sym}.yml"
      YAML.load_file(File.expand_path("~/.#{file}"))
          .with_indifferent_access
    end
  end
end
