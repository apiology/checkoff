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
require 'checkoff/internal/logging'

# https://developers.asana.com/reference/searchtasksforworkspace
module Checkoff
  # Run task searches against the Asana API
  class TaskSearches
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    include Logging
    include Asana::Resources::ResponseHelper

    # @!parse
    #   extend CacheMethod::ClassMethods

    # @param config [Hash<Symbol, Object>]
    # @param workspaces [Checkoff::Workspaces]
    # @param task_selectors [Checkoff::TaskSelectors]
    # @param projects [Checkoff::Projects]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    # @param search_url_parser [Checkoff::Internal::SearchUrl::Parser]
    # @param asana_resources_collection_class [Class<Asana::Resources::Collection>]
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

    # Perform an equivalent search API to an Asana search URL in the
    # web UI.  Not all URL parameters are supported; each one must be
    # added here manually.  In addition, not all are supported in the
    # Asana API in a compatible way, so they may result in more tasks
    # being fetched than actually returned as filtering is done
    # manually.
    #
    # @param [String] workspace_name
    # @param [String] url
    # @param [Array<String>] extra_fields
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def task_search(workspace_name, url, extra_fields: [])
      workspace = workspaces.workspace_or_raise(workspace_name)
      # @sg-ignore
      api_params, task_selector = @search_url_parser.convert_params(url)
      debug { "Task search params: api_params=#{api_params}, task_selector=#{task_selector}" }
      raw_task_search(api_params, workspace_gid: workspace.gid, task_selector: task_selector,
                                  extra_fields: extra_fields)
    end
    cache_method :task_search, LONG_CACHE_TIME

    # Perform a search using the Asana Task Search API:
    #
    #   https://developers.asana.com/reference/searchtasksforworkspace
    #
    # @param [Hash<Symbol, Object>] api_params
    # @param [String] workspace_gid
    # @param [String] url
    # @param [Array<String>] extra_fields
    # @param [Array] task_selector
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def raw_task_search(api_params, workspace_gid:, extra_fields: [], task_selector: [])
      # @sg-ignore
      path = "/workspaces/#{workspace_gid}/tasks/search"
      options = calculate_api_options(extra_fields)
      tasks = @asana_resources_collection_class.new(parse(client.get(path,
                                                                     params: api_params,
                                                                     options: options)),
                                                    type: Asana::Resources::Task,
                                                    client: client)

      if tasks.length == 100
        raise 'Too many results returned. ' \
              'Please narrow your search in ways expressible through task search API: ' \
              'https://developers.asana.com/reference/searchtasksforworkspace'
      end

      debug { "#{tasks.length} raw tasks returned" }

      tasks.select { |task| task_selectors.filter_via_task_selector(task, task_selector) }
    end

    # @return [Hash]
    def as_cache_key
      {}
    end

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
      # @return [void]
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

    # @return [Checkoff::TaskSelectors]
    attr_reader :task_selectors
    # @return [Checkoff::Projects]
    attr_reader :projects
    # @return [Checkoff::Workspaces]
    attr_reader :workspaces
    # @return [Asana::Client]
    attr_reader :client
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::TaskSearches.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
