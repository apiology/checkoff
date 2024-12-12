#!/usr/bin/env ruby
# typed: false

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/reference/resources

module Checkoff
  # Deal with Asana resources across different resource types
  class Resources
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    private_constant :MINUTE
    HOUR = MINUTE * 60
    private_constant :HOUR
    DAY = 24 * HOUR
    private_constant :DAY
    REALLY_LONG_CACHE_TIME = HOUR * 1
    private_constant :REALLY_LONG_CACHE_TIME
    LONG_CACHE_TIME = MINUTE * 15
    private_constant :LONG_CACHE_TIME
    SHORT_CACHE_TIME = MINUTE
    private_constant :SHORT_CACHE_TIME

    # @param config [Hash]
    # @param workspaces [Checkoff::Workspaces]
    # @param tasks [Checkoff::Tasks]
    # @param sections [Checkoff::Sections]
    # @param projects [Checkoff::Projects]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   tasks: Checkoff::Tasks.new(config: config),
                   sections: Checkoff::Sections.new(config: config),
                   projects: Checkoff::Projects.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @workspaces = workspaces
      @tasks = tasks
      @sections = sections
      @projects = projects
      @client = client
    end

    # Attempt to look up a GID, even in situations where we don't
    # have a resource type provided.
    #
    # @param gid [String]
    # @param resource_type [String,nil]
    #
    # @return [Array<([Asana::Resource, nil], [String,nil])>]
    def resource_by_gid(gid, resource_type: nil)
      %w[task section project].each do |resource_type_to_try|
        next unless [resource_type_to_try, nil].include?(resource_type)

        resource = method(:"fetch_#{resource_type_to_try}_gid").call(gid)
        return [resource, resource_type_to_try] if resource
      end
      [nil, nil]
    end

    private

    # @param gid [String]
    #
    # @return [Asana::Resources::Task, nil]
    def fetch_task_gid(gid)
      tasks.task_by_gid(gid, only_uncompleted: false)
    end

    # @param section_gid [String]
    #
    # @return [Asana::Resources::Section, nil]
    def fetch_section_gid(section_gid)
      sections.section_by_gid(section_gid)
    end

    # @param project_gid [String]
    #
    # @return [Asana::Resources::Project, nil]
    def fetch_project_gid(project_gid)
      projects.project_by_gid(project_gid)
    end

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Checkoff::Projects]
    attr_reader :projects

    # @return [Checkoff::Sections]
    attr_reader :sections

    # @return [Checkoff::Tasks]
    attr_reader :tasks

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./resources.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # # @sg-ignore
        # # @type [String]
        # workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # # @sg-ignore
        # # @type [String]
        # resource_name = ARGV[1] || raise('Please pass resource name as second argument')
        # resources = Checkoff::Resources.new
        # resource = resources.resource_or_raise(workspace_name, resource_name)
        # puts "Results: #{resource}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Resources.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
