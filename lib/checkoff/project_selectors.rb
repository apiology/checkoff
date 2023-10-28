#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'internal/project_selector_evaluator'
require_relative 'workspaces'
require_relative 'clients'

module Checkoff
  # Filter lists of projects using declarative selectors.
  class ProjectSelectors
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param config [Hash<Symbol, Object>]
    # @param workspaces [Checkoff::Workspaces]
    # @param projects [Checkoff::Projects]
    # @param custom_fields [Checkoff::CustomFields]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   projects: Checkoff::Projects.new(config: config),
                   custom_fields: Checkoff::CustomFields.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @workspaces = workspaces
      @projects = projects
      @custom_fields = custom_fields
      @client = client
    end

    # @param [Asana::Resources::Project] project
    # @param [Array<(Symbol, Array)>] project_selector Filter based on
    #        project details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    # @return [Boolean]
    def filter_via_project_selector(project, project_selector)
      evaluator = ProjectSelectorEvaluator.new(project: project, projects: projects, custom_fields: custom_fields)
      evaluator.evaluate(project_selector)
    end

    private

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Checkoff::Projects]
    attr_reader :projects

    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./project_selectors.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # project_selector_name = ARGV[1] || raise('Please pass project_selector name as second argument')
        # project_selectors = Checkoff::ProjectSelectors.new
        # project_selector = project_selectors.project_selector_or_raise(workspace_name, project_selector_name)
        # puts "Results: #{project_selector}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::ProjectSelectors.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
