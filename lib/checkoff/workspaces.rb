# frozen_string_literal: true

module Checkoff
  # Query different workspaces of Asana projects
  class Workspaces
    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   asana_client: Asana::Client)
      @config = config
      @asana_client = asana_client
    end

    def client
      @client ||= @asana_client.new do |c|
        c.authentication :access_token, @config[:personal_access_token]
      end
    end

    def default_workspace_id
      @config[:default_workspace_id]
    end

    def workspace_by_name(workspace_name)
      client.workspaces.find_all.find do |workspace|
        workspace.name == workspace_name
      end || raise("Could not find workspace #{workspace_name}")
    end
  end
end
