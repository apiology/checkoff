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
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   projects: Checkoff::Projects.new(config: config, client: client),
                   workspaces: Checkoff::Workspaces.new(config: config, client: client))
      @workspaces = workspaces
      @projects = projects
      @client = client
    end

    # @return [Enumerable<Asana::Resources::Task>]
    def tasks(workspace_name, tag_name,
              only_uncompleted: true,
              extra_fields: [])
      tag = tag_or_raise(workspace_name, tag_name)

      options = projects.task_options(extra_fields: extra_fields,
                                      only_uncompleted: only_uncompleted)

      params = build_params(options)

      Asana::Resources::Collection.new(parse(client.get("/tags/#{tag.gid}/tasks",
                                                        params: params, options: options[:options])),
                                       type: Asana::Resources::Task,
                                       client: client)
    end

    # @return [Asana::Resources::Tag]
    def tag_or_raise(workspace_name, tag_name)
      tag = tag(workspace_name, tag_name)
      raise "Could not find tag #{tag_name} under workspace #{workspace_name}." if tag.nil?

      tag
    end
    cache_method :tag_or_raise, LONG_CACHE_TIME

    # @return [Asana::Resources::Tag,nil]
    def tag(workspace_name, tag_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      tags = client.tags.get_tags_for_workspace(workspace_gid: workspace.gid)
      tags.find { |tag| tag.name == tag_name }
    end
    cache_method :tag, LONG_CACHE_TIME

    private

    attr_reader :workspaces, :projects, :client

    def build_params(options)
      { limit: options[:per_page], completed_since: options[:completed_since] }.reject do |_, v|
        v.nil? || Array(v).empty?
      end
    end

    # https://github.com/Asana/ruby-asana/blob/master/lib/asana/resource_includes/response_helper.rb#L7
    def parse(response)
      data = response.body.fetch('data')
      extra = response.body.except('data')
      [data, extra]
    end

    # bundle exec ./tags.rb
    # :nocov:
    class << self
      def run
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
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
