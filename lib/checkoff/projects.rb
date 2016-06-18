require_relative 'config_loader'

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

    def initialize(config: ConfigLoader.load(:asana),
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
        STDERR.puts "Looking for #{project_name} under #{workspace_name}"
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
