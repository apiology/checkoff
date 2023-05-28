# frozen_string_literal: true

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

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   asana_workspace: Asana::Resources::Workspace)
      @config = config
      @client = client
      @asana_workspace = asana_workspace
    end

    # Pulls an Asana workspace object
    def workspace(workspace_name)
      client.workspaces.find_all.find do |workspace|
        workspace.name == workspace_name
      end
    end

    def default_workspace
      @asana_workspace.find_by_id(client, default_workspace_gid)
    end

    # @param [String] workspace_name
    # @return [Asana::Resources::Workspace]
    def workspace_or_raise(workspace_name)
      workspace = workspace(workspace_name)
      raise "Could not find workspace #{workspace_name}" if workspace.nil?

      workspace
    end

    private

    attr_reader :client

    def default_workspace_gid
      @config.fetch(:default_workspace_gid)
    end
  end
end
