require_relative 'config_loader'

# frozen_string_literal: true
require 'cache_method'
require 'asana'

# Pull tasks from asana.com
#
# Convention:
#  _raw: Returns tasks objects, including section-tasks
#  _tasks: Returns task objects
#  _task_names: Returns an array of strings, no sections included
#  _by_section: Returns a hash from section name to array
module Checkoff
  # Work with projects in Asana
  class Projects
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    # XXX: Move low-level functions private

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

    def projects
      client.projects
    end
    cache_method :projects, LONG_CACHE_TIME

    def add_task(name,
                 workspace_id: default_workspace_id,
                 assignee_id: default_assignee_id)
      Asana::Resources::Task.create(client,
                                    assignee: assignee_id,
                                    workspace: workspace_id, name: name)
    end

    def default_workspace_id
      @config[:default_workspace_id]
    end

    def default_assignee_id
      @config[:default_assignee_id]
    end

    def user_by_name(name, workspace_id: raise)
      client.users.find_all(workspace: workspace_id).find do |user|
        print(user)
        user.name == name
      end || raise("Could not find user #{email}")
    end

    def workspace_by_name(workspace_name)
      client.workspaces.find_all.find do |workspace|
        workspace.name == workspace_name
      end || raise("Could not find workspace #{workspace_name}")
    end

    def projects_by_workspace_name(workspace_name)
      workspace = workspace_by_name(workspace_name)
      raise "Could not find workspace named #{workspace_name}" unless workspace
      projects.find_by_workspace(workspace: workspace.id)
    end

    def my_tasks(workspace_name)
      my_tasks = @config[:my_tasks]
      id = @config[:my_tasks][workspace_name] unless my_tasks.nil?
      if my_tasks.nil? || id.nil?
        raise "Please define [:my_tasks][#{workspace_name}] in config file"
      end
      projects.find_by_id(id)
    end

    def project(workspace_name, project_name)
      if project_name.is_a?(Symbol) && project_name.to_s.start_with?('my_tasks')
        my_tasks(workspace_name)
      else
        projects = projects_by_workspace_name(workspace_name)
        projects.find do |project|
          project.name == project_name
        end
      end
    end
    cache_method :project, LONG_CACHE_TIME

    def active_tasks(tasks)
      tasks.select { |task| task.completed_at.nil? }
    end

    def task_options
      {
        options: {
          fields: %w(name assignee_status completed_at due_at due_on),
        },
      }
    end

    def tasks_from_project(project)
      project.tasks(task_options).to_a
    end
    cache_method :tasks_from_project, LONG_CACHE_TIME
  end
end
