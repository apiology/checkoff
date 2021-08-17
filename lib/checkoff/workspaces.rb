# frozen_string_literal: true

require 'asana'

module Checkoff
  # Query different workspaces of Asana projects
  class Workspaces
    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @config = config
      @client = client
    end

    # Pulls an Asana workspace object
    def workspace_by_name(workspace_name)
      client.workspaces.find_all.find do |workspace|
        workspace.name == workspace_name
      end || raise("Could not find workspace named [#{workspace_name}]")
    end

    private

    attr_reader :client

    def default_workspace_gid
      @config.fetch(:default_workspace_gid)
    end
  end
end
