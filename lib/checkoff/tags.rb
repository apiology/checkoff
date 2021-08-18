#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'config_loader'
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

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @workspaces = workspaces
      @client = client
    end

    def tag_or_raise(workspace_name, tag_name)
      tag = tag(workspace_name, tag_name)
      raise "Could not find tag #{tag_name} under workspace #{workspace_name}." if tag.nil?

      tag
    end
    cache_method :tag_or_raise, LONG_CACHE_TIME

    def tag(workspace_name, tag_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      tags = client.tags.get_tags_for_workspace(workspace_gid: workspace.gid)
      tags.find { |tag| tag.name == tag_name }
    end
    cache_method :tag, LONG_CACHE_TIME

    private

    attr_reader :workspaces, :client

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
