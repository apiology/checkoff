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
        c.authentication :access_token, @config.fetch(:personal_access_token)
        c.default_headers 'asana-enable' => 'string_ids,new_sections'
        c.default_headers 'asana-disable' => 'new_user_task_lists'
      end
    end

    def default_workspace_gid
      @config.fetch(:default_workspace_gid)
    end

    def workspace_by_name(workspace_name)
      client.workspaces.find_all.find do |workspace|
        workspace.name == workspace_name
      end || raise("Could not find workspace named [#{workspace_name}]")
    end
  end
end
