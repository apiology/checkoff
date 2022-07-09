# frozen_string_literal: true

require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'
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

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client)
      @config = config
      @workspaces = workspaces
      @client = client
    end

    # Default options used in Asana API to pull taskso
    def task_options
      {
        per_page: 100,
        options: {
          fields: %w[name completed_at due_at due_on tags
                     memberships.project.gid memberships.section.name dependencies],
        },
      }
    end

    # pulls an Asana API project class given a name
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

    def project_or_raise(workspace_name, project_name)
      project = project(workspace_name, project_name)
      raise "Could not find project #{project_name} under workspace #{workspace_name}." if project.nil?

      project
    end
    cache_method :project_or_raise, LONG_CACHE_TIME

    # find uncompleted tasks in a list
    def active_tasks(tasks)
      tasks.select { |task| task.completed_at.nil? }
    end

    # pull task objects from a named project
    def tasks_from_project(project, only_uncompleted: true, extra_fields: [])
      options = task_options
      options[:completed_since] = '9999-12-01' if only_uncompleted
      options[:project] = project.gid
      options[:options][:fields] += extra_fields
      client.tasks.find_all(**options).to_a
    end
    cache_method :tasks_from_project, SHORT_CACHE_TIME

    private

    attr_reader :client

    def projects
      client.projects
    end
    cache_method :projects, LONG_CACHE_TIME

    def projects_by_workspace_name(workspace_name)
      workspace = @workspaces.workspace_or_raise(workspace_name)
      raise "Could not find workspace named #{workspace_name}" unless workspace

      projects.find_by_workspace(workspace: workspace.gid)
    end

    def my_tasks(workspace_name)
      workspace = @workspaces.workspace_or_raise(workspace_name)
      result = client.user_task_lists.get_user_task_list_for_user(user_gid: 'me',
                                                                  workspace: workspace.gid)
      gid = result.gid
      projects.find_by_id(gid)
    end
    cache_method :my_tasks, LONG_CACHE_TIME
  end
end
