#!/usr/bin/env ruby
# typed: true

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/docs/tags

module Checkoff
  # Work with tags in Asana
  class Tags
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    HOUR = T.let(MINUTE * 60, Numeric)
    DAY = T.let(24 * HOUR, Numeric)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, Numeric)
    LONG_CACHE_TIME = T.let(MINUTE * 15, Numeric)
    SHORT_CACHE_TIME = T.let(MINUTE, Numeric)

    # @param config [Checkoff::Internal::EnvFallbackConfigLoader]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    # @param projects [Checkoff::Projects]
    # @param workspaces [Checkoff::Workspaces]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   projects: Checkoff::Projects.new(config: config, client: client),
                   workspaces: Checkoff::Workspaces.new(config: config, client: client))
      @workspaces = T.let(workspaces, Checkoff::Workspaces)
      @projects = T.let(projects, Checkoff::Projects)
      @client = T.let(client, Asana::Client)
    end

    # @param workspace_name [String]
    # @param tag_name [String]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks(workspace_name, tag_name,
              only_uncompleted: true,
              extra_fields: [])
      tag = tag_or_raise(workspace_name, tag_name)
      tag_gid = tag.gid

      tasks_by_tag_gid(workspace_name, tag_gid,
                       only_uncompleted: only_uncompleted, extra_fields: extra_fields)
    end

    # @param workspace_name [String]
    # @param tag_gid [String]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks_by_tag_gid(workspace_name, tag_gid, only_uncompleted: true, extra_fields: [])
      options = projects.task_options(extra_fields: extra_fields,
                                      only_uncompleted: only_uncompleted)
      params = build_params(options)
      Asana::Resources::Collection.new(parse(client.get("/tags/#{tag_gid}/tasks",
                                                        params: params, options: options[:options])),
                                       type: Asana::Resources::Task,
                                       client: client)
    end

    # @param workspace_name [String]
    # @param tag_name [String]
    #
    # @return [Asana::Resources::Tag]
    def tag_or_raise(workspace_name, tag_name)
      t = tag(workspace_name, tag_name)

      raise "Could not find tag #{tag_name} under workspace #{workspace_name}." if t.nil?

      t
    end
    cache_method :tag_or_raise, LONG_CACHE_TIME

    # @param workspace_name [String]
    # @param tag_name [String]
    #
    # @return [Asana::Resources::Tag,nil]
    # @sg-ignore
    def tag(workspace_name, tag_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      tags = client.tags.get_tags_for_workspace(workspace_gid: workspace.gid)
      tags.find { |tag| tag.name == tag_name }
    end
    cache_method :tag, LONG_CACHE_TIME

    private

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces
    # @return [Checkoff::Projects]
    attr_reader :projects
    # @return [Asana::Client]
    attr_reader :client

    # @param options [Hash<Symbol, Object>]
    #
    # @sg-ignore
    # @return [Hash<Symbol, Object>]
    def build_params(options)
      { limit: options[:per_page], completed_since: options[:completed_since] }.reject do |_, v|
        v.nil? || Array(v).empty?
      end
    end

    # https://github.com/Asana/ruby-asana/blob/master/lib/asana/resource_includes/response_helper.rb#L7
    #
    # @param response [Asana::HttpClient::Response]
    #
    # @return [Array<Hash, Hash>]
    def parse(response)
      data = response.body.fetch('data')
      extra = response.body.except('data')
      [data, extra]
    end

    # bundle exec ./tags.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # @sg-ignore
        # @type [String]
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # @sg-ignore
        # @type [String]
        tag_name = ARGV[1] || raise('Please pass tag name as second argument')
        tags = Checkoff::Tags.new
        tag = tags.tag_or_raise(workspace_name, tag_name)
        puts "Results: #{tag}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Tags.run if abs_program_name == __FILE__
# :nocov:
