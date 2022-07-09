#!/bin/bash -eu

set -o pipefail

underscored_plural_name="${1:?underscored plural name of entities minus .rb}"
# Sorry, shellcheck, I can't express 'end of line' in a simple variable search and replace
# shellcheck disable=SC2001
underscored_singular_name=$(sed -e 's/s$//g' <<< "${underscored_plural_name}")
kabob_case_plural_name=${underscored_plural_name/_/-}
class_name="${2:?class name without Checkoff:: prefix}"

cat > "${underscored_plural_name}.rb" << EOF
#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/docs/${kabob_case_plural_name}

module Checkoff
  class ${class_name}
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @workspaces = workspaces
      @client = client
    end

    def ${underscored_singular_name}_or_raise(workspace_name, ${underscored_singular_name}_name)
      ${underscored_singular_name} = ${underscored_singular_name}(workspace_name, ${underscored_singular_name}_name)
      raise "Could not find ${underscored_singular_name} #{${underscored_singular_name}_name} under workspace #{workspace_name}." if ${underscored_singular_name}.nil?

      ${underscored_singular_name}
    end
    cache_method :${underscored_singular_name}_or_raise, LONG_CACHE_TIME

    def ${underscored_singular_name}(workspace_name, ${underscored_singular_name}_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      ${underscored_plural_name} = client.${underscored_plural_name}.get_${underscored_plural_name}_for_workspace(workspace_gid: workspace.gid)
      ${underscored_plural_name}.find { |${underscored_singular_name}| ${underscored_singular_name}.name == ${underscored_singular_name}_name }
    end
    cache_method :${underscored_singular_name}, LONG_CACHE_TIME

    private

    attr_reader :workspaces, :client

    # bundle exec ./${underscored_plural_name}.rb
    # :nocov:
    class << self
      def run
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        ${underscored_singular_name}_name = ARGV[1] || raise('Please pass ${underscored_singular_name} name as second argument')
        ${underscored_plural_name} = Checkoff::${class_name}.new
        ${underscored_singular_name} = ${underscored_plural_name}.${underscored_singular_name}_or_raise(workspace_name, ${underscored_singular_name}_name)
        puts "Results: #{${underscored_singular_name}}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path(\$PROGRAM_NAME)
Checkoff::${class_name}.run if abs_program_name == __FILE__
# :nocov:
EOF

chmod +x "${underscored_plural_name}.rb"
git add "${underscored_plural_name}.rb"

echo "You can start by running 'bundle exec ./${underscored_plural_name}.rb' and tweaking from there"
