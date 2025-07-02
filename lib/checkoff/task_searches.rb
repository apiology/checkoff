#!/usr/bin/env ruby
# typed: true

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

    # @param config [Hash{Symbol => Object}, Checkoff::Internal::EnvFallbackConfigLoader]
    # @param workspaces [Checkoff::Workspaces]
    # @param task_selectors [Checkoff::TaskSelectors]
    # @param projects [Checkoff::Projects]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    # @param search_url_parser [Checkoff::Internal::SearchUrl::Parser]
    # @param asana_resources_collection_class [Class<Asana::Resources::Collection>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config:),
                   task_selectors: Checkoff::TaskSelectors.new(config:),
                   projects: Checkoff::Projects.new(config:),
                   clients: Checkoff::Clients.new(config:),
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
      raw_task_search(api_params, workspace_gid: workspace.gid, task_selector:,
                                  extra_fields:)
    end
    cache_method :task_search, SHORT_CACHE_TIME

    # Perform a search using the Asana Task Search API:
    #
    #   https://developers.asana.com/reference/searchtasksforworkspace
    #
    # @param [Hash{String => Object}] api_params
    # @param [String] workspace_gid
    # @param [Array<String>] extra_fields
    # @param [Symbol, Array<Symbol, Integer, Array>] task_selector
    # @param [Boolean] fetch_all Ensure all results are provided by manually paginating
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def raw_task_search(api_params,
                        workspace_gid:, extra_fields: [], task_selector: [],
                        fetch_all: true)
      # @sg-ignore
      tasks = api_task_search_request(api_params, workspace_gid:, extra_fields:)

      if fetch_all && tasks.count == 100
        # @sg-ignore
        tasks = iterated_raw_task_search(api_params, workspace_gid:, extra_fields:)
      end

      debug { "#{tasks.count} raw tasks returned" }

      return tasks if task_selector.empty?

      tasks.select do |task|
        task_selectors.filter_via_task_selector(task, task_selector)
      end
    end

    # @return [Hash]
    def as_cache_key
      {}
    end

    private

    # Perform a search using the Asana Task Search API:
    #
    #   https://developers.asana.com/reference/searchtasksforworkspace
    #
    # @param [Hash{String => Object}] api_params
    # @param [String] workspace_gid
    # @param [Array<String>] extra_fields
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def api_task_search_request(api_params, workspace_gid:, extra_fields:)
      path = "/workspaces/#{workspace_gid}/tasks/search"
      options = calculate_api_options(extra_fields)
      @asana_resources_collection_class.new(parse(client.get(path,
                                                             params: api_params,
                                                             options:)),
                                            type: Asana::Resources::Task,
                                            client:)
    end

    # Perform a search using the Asana Task Search API and use manual pagination to
    # ensure all results are returned:
    #
    #   https://developers.asana.com/reference/searchtasksforworkspace
    #
    #     "However, you can paginate manually by sorting the search
    #     results by their creation time and then modifying each
    #     subsequent query to exclude data you have already seen." -
    #     see sort_by field at
    #     https://developers.asana.com/reference/searchtasksforworkspace
    #
    # @param [Hash{String => Object}] api_params
    # @param [String] workspace_gid
    # @param [String] url
    # @param [Array<String>] extra_fields
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def iterated_raw_task_search(api_params, workspace_gid:, extra_fields:)
      # https://developers.asana.com/reference/searchtasksforworkspace
      tasks = []
      new_api_params = api_params.dup
      original_sort_by = new_api_params.delete('sort_by')
      # defaults to false
      original_sort_ascending = new_api_params.delete('sort_ascending')
      original_created_at_before = new_api_params.delete('created_at.before')
      raise 'Teach me how to handle original_created_at_before' unless original_created_at_before.nil?

      new_api_params['sort_by'] = 'created_at'

      Kernel.loop do
        # Get the most recently created results, then iterate on until we're out of results

        # @type [Array<Asana::Resources::Task>]
        task_batch = raw_task_search(new_api_params,
                                     workspace_gid:, extra_fields: extra_fields + ['created_at'],
                                     fetch_all: false).to_a
        oldest = task_batch.to_a.last

        break if oldest.nil?

        new_api_params['created_at.before'] = oldest.created_at

        tasks.concat(task_batch.to_a)
      end
      unless original_sort_by.nil? || original_sort_by == 'created_at'
        raise "Teach me how to handle original_sort_by: #{original_sort_by.inspect}"
      end

      raise 'Teach me how to handle original_sort_ascending' unless original_sort_ascending.nil?

      tasks
    end

    # @param [Array<String>] extra_fields
    # @sg-ignore
    # @return [Hash{Symbol => undefined}]
    def calculate_api_options(extra_fields)
      # @type [Hash{Symbol => undefined}]
      all_options = projects.task_options(extra_fields: ['custom_fields'] + extra_fields)
      all_options[:options]
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
