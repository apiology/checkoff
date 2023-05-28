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
    # @sg-ignore
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    # @sg-ignore
    REALLY_LONG_CACHE_TIME = HOUR * 1
    # @sg-ignore
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @!parse
    #   extend CacheMethod::ClassMethods

    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client))
      @config = config
      @workspaces = workspaces
      @client = client
    end

    # Default options used in Asana API to pull taskso
    # @return [Hash<Symbol, Object>]
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
    # @param [String] workspace_name
    # @param [String] project_name
    # @return [Asana::Resources::Project, nil]
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

    # @param workspace_name [String]
    # @param project_name [String]
    # @return [Asana::Resources::Project]
    def project_or_raise(workspace_name, project_name)
      p = project(workspace_name, project_name)
      raise "Could not find project #{project_name} under workspace #{workspace_name}." if p.nil?

      p
    end
    cache_method :project_or_raise, LONG_CACHE_TIME

    # find uncompleted tasks in a list
    # @param [Array<Asana::Resources::Task>] tasks
    # @return [Array<Asana::Resources::Task>]
    def active_tasks(tasks)
      tasks.select { |task| task.completed_at.nil? }
    end

    # pull task objects from a named project
    # @sg-ignore
    # @param [Asana::Resources::Project] project
    # @param [Boolean] only_uncompleted
    # @param [Array<String>] extra_fields
    # @return [Array<Asana::Resources::Task>]
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

    # @sg-ignore
    def projects
      client.projects
    end
    cache_method :projects, LONG_CACHE_TIME

    # @sg-ignore
    # @param [String] workspace_name
    # @return [Array<Asana::Resources::Project>]
    def projects_by_workspace_name(workspace_name)
      workspace = @workspaces.workspace_or_raise(workspace_name)
      raise "Could not find workspace named #{workspace_name}" unless workspace

      projects.find_by_workspace(workspace: workspace.gid)
    end

    # @sg-ignore
    # @param [String] workspace_name
    # @return [Asana::Resources::Project]
    def my_tasks(workspace_name)
      workspace = @workspaces.workspace_or_raise(workspace_name)
      # @sg-ignore
      # @type [Asana::Resources::UserTaskList]
      result = client.user_task_lists.get_user_task_list_for_user(user_gid: 'me',
                                                                  workspace: workspace.gid)
      gid = result.gid
      projects.find_by_id(gid)
    end
    cache_method :my_tasks, LONG_CACHE_TIME
  end
end
