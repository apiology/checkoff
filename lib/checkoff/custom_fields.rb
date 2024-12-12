#!/usr/bin/env ruby
# typed: true

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
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param config [Hash]
    # @param workspaces [Checkoff::Workspaces]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client))
      @workspaces = workspaces
      @client = client
    end

    # @param workspace_name [String]
    # @param custom_field_name [String]
    #
    # @return [Asana::Resources::CustomField]
    def custom_field_or_raise(workspace_name, custom_field_name)
      cf = custom_field(workspace_name, custom_field_name)
      raise "Could not find custom_field #{custom_field_name} under workspace #{workspace_name}." if cf.nil?

      cf
    end
    cache_method :custom_field_or_raise, LONG_CACHE_TIME

    # @param workspace_name [String]
    # @param custom_field_name [String]
    #
    # @sg-ignore
    # @return [Asana::Resources::CustomField,nil]
    def custom_field(workspace_name, custom_field_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      custom_fields = client.custom_fields.get_custom_fields_for_workspace(workspace_gid: workspace.gid)
      custom_fields.find { |custom_field| custom_field.name == custom_field_name }
    end
    cache_method :custom_field, LONG_CACHE_TIME

    # @param resource [Asana::Resources::Project,Asana::Resources::Task]
    # @param custom_field_gid [String]
    #
    # @return [Array<String>]
    def resource_custom_field_values_gids_or_raise(resource, custom_field_gid)
      custom_field = resource_custom_field_by_gid_or_raise(resource, custom_field_gid)

      resource_custom_field_enum_values(custom_field).flat_map do |enum_value|
        find_gids(custom_field, enum_value)
      end
    rescue StandardError => e
      raise "Could not process custom field with gid #{custom_field_gid} " \
            "in gid #{resource.gid} with custom fields #{resource.custom_fields.inspect}: #{e}"
    end

    # @param resource [Asana::Resources::Project,Asana::Resources::Task]
    # @param custom_field_name [String]
    # @return [Array<String>]
    def resource_custom_field_values_names_by_name(resource, custom_field_name)
      custom_field = resource_custom_field_by_name(resource, custom_field_name)
      return [] if custom_field.nil?

      resource_custom_field_enum_values(custom_field).flat_map do |enum_value|
        if enum_value.nil?
          []
        else
          [enum_value.fetch('name')]
        end
      end
    end

    # @sg-ignore
    # @param project [Asana::Resources::Task,Asana::Resources::Project]
    # @param custom_field_name [String]
    # @return [Hash, nil]
    def resource_custom_field_by_name(resource, custom_field_name)
      # @sg-ignore
      # @type [Array<Hash>]
      custom_fields = resource.custom_fields
      if custom_fields.nil?
        raise "custom fields not found on resource - did you add 'custom_fields' in your extra_fields argument?"
      end

      # @sg-ignore
      # @type [Hash, nil]
      custom_fields.find { |field| field.fetch('name') == custom_field_name }
    end

    # @param resource [Asana::Resources::Task,Asana::Resources::Project]
    # @param custom_field_name [String]
    # @return [Hash]
    def resource_custom_field_by_name_or_raise(resource, custom_field_name)
      custom_field = resource_custom_field_by_name(resource, custom_field_name)
      if custom_field.nil?
        raise "Could not find custom field with name #{custom_field_name} " \
              "in gid #{resource.gid} with custom fields #{resource.custom_fields}"
      end
      custom_field
    end

    # @param resource [Asana::Resources::Project,Asana::Resources::Task]
    # @param custom_field_gid [String]
    # @return [Hash]
    def resource_custom_field_by_gid_or_raise(resource, custom_field_gid)
      # @type [Array<Hash>]
      custom_fields = resource.custom_fields
      if custom_fields.nil?
        raise "Could not find custom_fields under project (was 'custom_fields' included in 'extra_fields'?)"
      end

      # @sg-ignore
      # @type [Hash, nil]
      matched_custom_field = custom_fields.find { |data| data.fetch('gid') == custom_field_gid }
      if matched_custom_field.nil?
        raise "Could not find custom field with gid #{custom_field_gid} " \
              "in gid #{resource.gid} with custom fields #{custom_fields}"
      end

      matched_custom_field
    end

    private

    # @param custom_field [Hash{String => [Hash,Array<Hash>]}]
    #
    # @sg-ignore
    # @return [Array<Hash>]
    def resource_custom_field_enum_values(custom_field)
      resource_subtype = custom_field.fetch('resource_subtype')
      case resource_subtype
      when 'enum'
        # @type [Array<Hash>]
        [custom_field.fetch('enum_value')]
      when 'multi_enum'
        # @type [Array<Hash>]
        custom_field.fetch('multi_enum_values')
      else
        raise "Teach me how to handle resource_subtype #{resource_subtype}"
      end
    end

    # @param custom_field [Hash]
    # @param enum_value [Hash{String => String}, nil]
    # @return [Array<String>]
    def find_gids(custom_field, enum_value)
      if enum_value.nil?
        []
      else
        [enum_value.fetch('gid')]
      end
    end

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./custom_fields.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # @sg-ignore
        # @type [String]
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # @sg-ignore
        # @type [String]
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
