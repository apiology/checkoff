#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'sections'
require_relative 'portfolios'
require_relative 'workspaces'
require_relative 'internal/config_loader'
require_relative 'internal/task_timing'
require_relative 'internal/task_hashes'
require 'asana'

module Checkoff
  # Pull tasks from Asana
  class Tasks
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    # @param config [Hash<Symbol, Object>]
    # @param client [Asana::Client]
    # @param workspaces [Checkoff::Workspaces]
    # @param sections [Checkoff::Sections]
    # @param portfolios [Checkoff::Portfolios]
    # @param time_class [Class<Time>]
    # @param date_class [Class<Date>]
    # @param asana_task [Class<Asana::Resources::Task>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client),
                   sections: Checkoff::Sections.new(config: config,
                                                    client: client),
                   portfolios: Checkoff::Portfolios.new(config: config,
                                                        client: client),
                   time_class: Time,
                   date_class: Date,
                   asana_task: Asana::Resources::Task)
      @config = config
      @sections = sections
      @time_class = time_class
      @date_class = date_class
      @asana_task = asana_task
      @client = client
      @portfolios = portfolios
      @workspaces = workspaces
    end

    # Indicates a task is ready for a person to work on it.  This is
    # subtly different than what is used by Asana to mark a date as
    # red/green!  A task is ready if it is not dependent on an
    # incomplete task and one of these is true:
    #
    # * start is null and due on is today
    # * start is null and due at is before now
    # * start on is today
    # * start at is before now
    #
    # @param task [Asana::Resources::Task]
    # @param ignore_dependencies [Boolean]
    def task_ready?(task, ignore_dependencies: false)
      return false if !ignore_dependencies && incomplete_dependencies?(task)

      start = task_timing.start_time(task)
      due = task_timing.due_time(task)

      return true if start.nil? && due.nil?

      (start || due) < @time_class.now
    end

    # Pull a specific task by name
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil, Symbol]
    # @param task_name [String]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    # @sg-ignore
    # @return [Asana::Resources::Task, nil]
    def task(workspace_name, project_name, task_name,
             section_name: :unspecified,
             only_uncompleted: true,
             extra_fields: [])
      # @sg-ignore
      t = tasks(workspace_name,
                project_name,
                section_name: section_name,
                only_uncompleted: only_uncompleted,
                extra_fields: extra_fields)
      t.find { |task| task.name == task_name }
    end
    cache_method :task, SHORT_CACHE_TIME

    # Pull a specific task by name
    # @param task_gid [String]
    # @param extra_fields [Array<String>]
    # @return [Asana::Resources::Task, nil]
    def task_by_gid(task_gid,
                    extra_fields: [])
      options = projects.task_options.fetch(:options, {})
      options[:fields] += extra_fields
      client.tasks.find_by_id(task_gid, options: options)
    end
    cache_method :task_by_gid, SHORT_CACHE_TIME

    # @param name [String]
    # @param workspace_gid [String]
    # @param assignee_gid [String]
    # @return [Asana::Resources::Task]
    def add_task(name,
                 workspace_gid: @workspaces.default_workspace_gid,
                 assignee_gid: default_assignee_gid)
      @asana_task.create(client,
                         assignee: assignee_gid,
                         workspace: workspace_gid, name: name)
    end

    # @param task [Asana::Resources::Task]
    # @return [String] end-user URL to the task in question
    def url_of_task(task)
      "https://app.asana.com/0/0/#{task.gid}/f"
    end

    # @param task [Asana::Resources::Task]
    def incomplete_dependencies?(task)
      # Avoid a redundant fetch.  Unfortunately, Ruby SDK allows
      # dependencies to be fetched along with other attributes--but
      # then doesn't use it and does another HTTP GET!  At least this
      # way we can skip the extra HTTP GET in the common case when
      # there are no dependencies.
      #
      # https://github.com/Asana/ruby-asana/issues/125

      # @sg-ignore
      # @type [Enumerable<Asana::Resources::Task>, nil]
      dependencies = task.instance_variable_get(:@dependencies)
      dependencies = task.dependencies.map { |dependency| { 'gid' => dependency.gid } } if dependencies.nil?

      dependencies.any? do |parent_task_info|
        # the real bummer though is that asana doesn't let you fetch
        # the completion status of dependencies, so we need to do this
        # regardless:
        parent_task_gid = parent_task_info.fetch('gid')
        parent_task = @asana_task.find_by_id(client, parent_task_gid,
                                             options: { fields: ['completed'] })
        !parent_task.completed
      end
    end

    # Builds on the standard API representation of an Asana task with some
    # convenience keys:
    #
    # <regular keys from API response>
    # +
    # unwrapped:
    #  membership_by_section_gid: Hash<String, Hash (membership)>
    #  membership_by_project_gid: Hash<String, Hash (membership)>
    #  membership_by_project_name: Hash<String, Hash (membership)>
    # task: String (name)
    #
    # @param task [Asana::Resources::Task]
    # @return [Hash]
    def task_to_h(task)
      task_hashes.task_to_h(task)
    end

    # @param task [Asana::Resources::Task]
    # @param portfolio_name [String]
    # @param workspace_name [String]
    def in_portfolio_named?(task,
                            portfolio_name,
                            workspace_name: @workspaces.default_workspace.name)
      portfolio_projects = @portfolios.projects_in_portfolio(workspace_name, portfolio_name)
      task.memberships.any? do |membership|
        project_gid = membership.fetch('project').fetch('gid')
        portfolio_projects.any? do |portfolio_project|
          portfolio_project.gid == project_gid
        end
      end
    end

    private

    # @return [Checkoff::Internal::TaskTiming]
    def task_timing
      @task_timing ||= Checkoff::Internal::TaskTiming.new(time_class: @time_class, date_class: @date_class)
    end

    # @return [Checkoff::Internal::TaskHashes]
    def task_hashes
      @task_hashes ||= Checkoff::Internal::TaskHashes.new
    end

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil, Symbol<:unspecified>]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks(workspace_name, project_name,
              only_uncompleted:, extra_fields:, section_name: :unspecified)
      if section_name == :unspecified
        project = projects.project_or_raise(workspace_name, project_name)
        projects.tasks_from_project(project,
                                    only_uncompleted: only_uncompleted,
                                    extra_fields: extra_fields)
      else
        @sections.tasks(workspace_name, project_name, section_name,
                        only_uncompleted: only_uncompleted,
                        extra_fields: extra_fields)
      end
    end
    cache_method :tasks, SHORT_CACHE_TIME

    # @return [Asana::Client]
    attr_reader :client

    # @return [Checkoff::Projects]
    def projects
      @projects ||= @sections.projects
    end

    # @sg-ignore
    # @return [String]
    def default_assignee_gid
      @config.fetch(:default_assignee_gid)
    end
  end
end
