# frozen_string_literal: true

require_relative 'internal/config_loader'
require_relative 'internal/project_hashes'
require_relative 'internal/project_timing'
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
    MEDIUM_CACHE_TIME = MINUTE * 5
    SHORT_CACHE_TIME = MINUTE

    # @!parse
    #   extend CacheMethod::ClassMethods

    # @param config [Hash<Symbol, Object>]
    # @param client [Asana::Client]
    # @param workspaces [Checkoff::Workspaces]
    # @param project_hashes [Checkoff::Internal::ProjectHashes]
    # @param project_timing [Checkoff::Internal::ProjectTiming]
    # @param timing [Checkoff::Timing]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client),
                   project_hashes: Checkoff::Internal::ProjectHashes.new,
                   project_timing: Checkoff::Internal::ProjectTiming.new(client: client),
                   timing: Checkoff::Timing.new)
      @config = config
      @workspaces = workspaces
      @client = client
      @project_hashes = project_hashes
      @project_timing = project_timing
      @timing = timing
    end

    # Default options used in Asana API to pull tasks
    # @return [Hash<Symbol, Object>]
    def task_options
      {
        per_page: 100,
        options: {
          fields: %w[name completed_at start_at start_on due_at due_on tags
                     memberships.project.gid memberships.project.name
                     memberships.section.name dependencies],
        },
      }
    end

    # pulls an Asana API project class given a name
    # @param [String] workspace_name
    # @param [String] project_name
    # @param [Array<String>] extra_fields
    #
    # @return [Asana::Resources::Project, nil]
    def project(workspace_name, project_name, extra_fields: [])
      if project_name.is_a?(Symbol) && project_name.to_s.start_with?('my_tasks')
        my_tasks(workspace_name)
      else
        # @type [Enumerable<Asana::Resources::Project>]
        ps = projects_by_workspace_name(workspace_name, extra_fields: extra_fields)
        ps.find do |project|
          project.name == project_name
        end
      end
    end
    cache_method :project, LONG_CACHE_TIME

    # @param workspace_name [String]
    # @param project_name [String]
    # @param [Array<String>] extra_fields
    #
    # @return [Asana::Resources::Project]
    def project_or_raise(workspace_name, project_name, extra_fields: [])
      p = project(workspace_name, project_name, extra_fields: extra_fields)
      raise "Could not find project #{project_name.inspect} under workspace #{workspace_name}." if p.nil?

      p
    end
    cache_method :project_or_raise, LONG_CACHE_TIME

    # @param gid [String]
    # @param [Array<String>] extra_fields
    #
    # @return [Asana::Resources::Project]
    def project_by_gid(gid, extra_fields: [])
      projects.find_by_id(gid, options: { fields: %w[name] + extra_fields })
    end
    cache_method :project_by_gid, LONG_CACHE_TIME

    # find uncompleted tasks in a list
    # @param [Enumerable<Asana::Resources::Task>] tasks
    # @return [Enumerable<Asana::Resources::Task>]
    def active_tasks(tasks)
      tasks.select { |task| task.completed_at.nil? }
    end

    # pull task objects from a named project
    # @param [Asana::Resources::Project] project
    # @param [Boolean] only_uncompleted
    # @param [Array<String>] extra_fields
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks_from_project(project,
                           only_uncompleted: true,
                           extra_fields: [])
      options = task_options
      options[:completed_since] = '9999-12-01' if only_uncompleted
      options[:project] = project.gid
      options[:options][:fields] += extra_fields
      client.tasks.find_all(**options)
    end
    cache_method :tasks_from_project, SHORT_CACHE_TIME

    # @param [String] workspace_name
    # @param [Array<String>] extra_fields
    # @return [Enumerable<Asana::Resources::Project>]
    def projects_by_workspace_name(workspace_name, extra_fields: [])
      workspace = @workspaces.workspace_or_raise(workspace_name)
      options = { fields: %w[name] + extra_fields }
      projects.find_by_workspace(workspace: workspace.gid, per_page: 100, options: options)
    end
    # 15 minute cache resulted in 'Your pagination token has expired'
    cache_method :projects_by_workspace_name, MEDIUM_CACHE_TIME

    # @param project_obj [Asana::Resources::Project]
    # @param project [String, Symbol<:not_specified, :my_tasks>]
    #
    # @return [Hash]
    def project_to_h(project_obj, project: :not_specified)
      project_hashes.project_to_h(project_obj, project: project)
    end

    # Indicates a project is ready for a person to work on it.  This
    # is subtly different than what is used by Asana to mark a date as
    # red/green!
    #
    # A project is ready if there is no start date, or if the start
    # date is today or in the past.
    #
    # @param project [Asana::Resources::Project]
    # @param period [Symbol<:now_or_before,:this_week>]
    def project_ready?(project, period: :now_or_before)
      in_period?(project, :ready, period)
    end

    # @param project [Asana::Resources::Project]
    # @param field_name [Symbol,Array]
    # @param period [Symbol<:now_or_before,:this_week>,Array] See Checkoff::Timing#in_period?
    def in_period?(project, field_name, period)
      # @type [Date,Time,nil]
      project_date = project_timing.date_or_time_field_by_name(project, field_name)

      timing.in_period?(project_date, period)
    end

    private

    # @return [Checkoff::Timing]
    attr_reader :timing

    # @return [Checkoff::Internal::ProjectTiming]
    attr_reader :project_timing

    # @return [Checkoff::Internal::ProjectHashes]
    attr_reader :project_hashes

    # @return [Asana::Client]
    attr_reader :client

    # @return [Asana::ProxiedResourceClasses::Project]
    def projects
      client.projects
    end
    cache_method :projects, LONG_CACHE_TIME

    # @param [String] workspace_name
    # @return [Asana::Resources::Project]
    def my_tasks(workspace_name)
      workspace = @workspaces.workspace_or_raise(workspace_name)
      # @sg-ignore
      result = client.user_task_lists.get_user_task_list_for_user(user_gid: 'me',
                                                                  workspace: workspace.gid)
      gid = result.gid
      projects.find_by_id(gid)
    end
    cache_method :my_tasks, LONG_CACHE_TIME
  end
end
