#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'
require 'asana/resource_includes/collection'
require 'asana/resource_includes/response_helper'

require 'checkoff/internal/search_url_parser'

# https://developers.asana.com/docs/task-searches
module Checkoff
  # Run task searches against the Asana API
  class TaskSearches
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    include Asana::Resources::ResponseHelper

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   search_url_parser: Checkoff::Internal::SearchUrlParser.new)
      @workspaces = workspaces
      @client = client
      @search_url_parser = search_url_parser
    end

    def task_search(workspace_name, url)
      workspace = workspaces.workspace_or_raise(workspace_name)
      api_params = @search_url_parser.convert_params(url)
      path = "/workspaces/#{workspace.gid}/tasks/search"
      options = {}
      Asana::Resources::Collection.new(parse(client.get(path, params: api_params, options: options)),
                                       type: Asana::Resources::Task, client: client)
    end
    cache_method :task_search, LONG_CACHE_TIME

    attr_reader :workspaces, :client

    # bundle exec ./task_searches.rb
    # :nocov:
    class << self
      def run
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        url = ARGV[1] || raise('Please pass task search URL as second argument')
        task_searches = Checkoff::TaskSearches.new
        task_search = task_searches.task_search(workspace_name, url)
        puts "Results: #{task_search}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::TaskSearches.run if abs_program_name == __FILE__
# :nocov:
