#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'projects'
require_relative 'clients'
require_relative 'task_selectors'
require 'asana/resource_includes/collection'
require 'asana/resource_includes/response_helper'

require 'checkoff/internal/search_url'

# https://developers.asana.com/reference/searchtasksforworkspace
module Checkoff
  # Run task searches against the Asana API
  class TaskSearches
    MINUTE = 60
    # @sg-ignore
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    # @sg-ignore
    REALLY_LONG_CACHE_TIME = HOUR * 1
    # @sg-ignore
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    include Asana::Resources::ResponseHelper

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   task_selectors: Checkoff::TaskSelectors.new(config: config),
                   projects: Checkoff::Projects.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   search_url_parser: Checkoff::Internal::SearchUrl::Parser.new,
                   asana_resources_collection_class: Asana::Resources::Collection)
      @workspaces = workspaces
      @task_selectors = task_selectors
      @projects = projects
      @client = client
      @search_url_parser = search_url_parser
      @asana_resources_collection_class = asana_resources_collection_class
    end

    # @param [String] workspace_name
    # @param [String] url
    # @param [Array<String>] extra_fields
    # @return [Array<Asana::Resources::Task>]
    def task_search(workspace_name, url, extra_fields: [])
      workspace = workspaces.workspace_or_raise(workspace_name)
      api_params, task_selector = @search_url_parser.convert_params(url)
      path = "/workspaces/#{workspace.gid}/tasks/search"
      options = calculate_api_options(extra_fields)
      tasks = @asana_resources_collection_class.new(parse(client.get(path,
                                                                     params: api_params,
                                                                     options: options)),
                                                    type: Asana::Resources::Task,
                                                    client: client)
      tasks.select { |task| task_selectors.filter_via_task_selector(task, task_selector) }
    end
    # @sg-ignore
    cache_method :task_search, LONG_CACHE_TIME

    private

    # @param [Array<String>] extra_fields
    # @return [Hash<Symbol, Object>]
    def calculate_api_options(extra_fields)
      # @type [Hash<Symbol, Object>]
      options = projects.task_options[:options]
      options[:fields] += ['custom_fields']
      options[:fields] += extra_fields
      options
    end

    # bundle exec ./task_searches.rb
    # :nocov:
    class << self
      def run
        # @sg-ignore
        # @type [String]
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # @sg-ignore
        # @type [String]
        url = ARGV[1] || raise('Please pass task search URL as second argument')
        task_searches = Checkoff::TaskSearches.new
        task_search = task_searches.task_search(workspace_name, url)
        puts "Results: #{task_search}"
      end
    end
    # :nocov:

    attr_reader :task_selectors, :projects, :workspaces, :client
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::TaskSearches.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
