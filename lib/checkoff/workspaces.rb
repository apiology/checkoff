# typed: true
# frozen_string_literal: true

require 'asana'
require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'clients'

# https://developers.asana.com/docs/workspaces

module Checkoff
  # Query different workspaces of Asana projects
  class Workspaces
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @!parse
    #   extend CacheMethod::ClassMethods

    # @param config [Checkoff::Internal::EnvFallbackConfigLoader]
    # @param client [Asana::Client]
    # @param asana_workspace [Class<Asana::Resources::Workspace>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config:).client,
                   asana_workspace: Asana::Resources::Workspace)
      @config = config
      @client = client
      @asana_workspace = asana_workspace
    end

    # Pulls an Asana workspace object
    # @param [String] workspace_name
    # @sg-ignore
    # @return [Asana::Resources::Workspace, nil]
    def workspace(workspace_name)
      client.workspaces.find_all.find do |workspace|
        workspace.name == workspace_name
      end
    end
    cache_method :workspace, LONG_CACHE_TIME

    # @return [Asana::Resources::Workspace]
    def default_workspace
      @asana_workspace.find_by_id(client, default_workspace_gid)
    end
    cache_method :default_workspace, REALLY_LONG_CACHE_TIME

    # @param [String] workspace_name
    # @return [Asana::Resources::Workspace]
    def workspace_or_raise(workspace_name)
      w = workspace(workspace_name)
      raise "Could not find workspace #{workspace_name}" if w.nil?

      w
    end

    # @sg-ignore
    # @return [String]
    def default_workspace_gid
      @config.fetch(:default_workspace_gid)
    end

    private

    # @return [Asana::Client]
    attr_reader :client
  end
end
