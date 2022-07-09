#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/docs/custom-fields

module Checkoff
  # Work with custom fields in Asana
  class CustomFields
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

    def custom_field_or_raise(workspace_name, custom_field_name)
      custom_field = custom_field(workspace_name, custom_field_name)
      raise "Could not find custom_field #{custom_field_name} under workspace #{workspace_name}." if custom_field.nil?

      custom_field
    end
    cache_method :custom_field_or_raise, LONG_CACHE_TIME

    def custom_field(workspace_name, custom_field_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      custom_fields = client.custom_fields.get_custom_fields_for_workspace(workspace_gid: workspace.gid)
      custom_fields.find { |custom_field| custom_field.name == custom_field_name }
    end
    cache_method :custom_field, LONG_CACHE_TIME

    private

    attr_reader :workspaces, :client

    # bundle exec ./custom_fields.rb
    # :nocov:
    class << self
      def run
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        custom_field_name = ARGV[1] || raise('Please pass custom_field name as second argument')
        custom_fields = Checkoff::CustomFields.new
        custom_field = custom_fields.custom_field_or_raise(workspace_name, custom_field_name)
        puts "Results: #{custom_field}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::CustomFields.run if abs_program_name == __FILE__
# :nocov:
