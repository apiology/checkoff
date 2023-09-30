#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/docs/project-selectors

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
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @workspaces = workspaces
      @client = client
    end

    # @param [Asana::Resources::Project] project
    # @param [Array<(Symbol, Array)>] project_selector Filter based on
    #        project details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    # @return [Boolean]
    def filter_via_project_selector(project, project_selector)
      if project_selector == [:custom_field_values_contain_any_value, 'Project attributes', ['timeline']]
        custom_field = project.custom_fields.find { |field| field.fetch('name') == 'Project attributes' }

        return false if custom_field.nil?

        # @sg-ignore
        # @type [Hash, nil]
        timeline = custom_field.fetch('multi_enum_values').find do |multi_enum_value|
          multi_enum_value.fetch('name') == 'timeline'
        end

        return !timeline.nil?
      end

      raise "Teach me how to evaluate #{project} against #{project_selector}"
    end

    private

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

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
