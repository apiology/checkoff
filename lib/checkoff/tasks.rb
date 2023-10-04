#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'sections'
require_relative 'workspaces'
require_relative 'internal/config_loader'
require 'asana'

module Checkoff
  # Pull tasks from Asana
  class Tasks
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
    # @param time_class [Class<Time>]
    # @param asana_task [Class<Asana::Resources::Task>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client),
                   sections: Checkoff::Sections.new(config: config,
                                                    client: client),
                   time_class: Time,
                   asana_task: Asana::Resources::Task)
      @config = config
      @sections = sections
      @time_class = time_class
      @asana_task = asana_task
      @client = client
      @workspaces = workspaces
    end

    # @param task [Asana::Resources::Task]
    # @param ignore_dependencies [Boolean]
    def task_ready?(task, ignore_dependencies: false)
      return false if !ignore_dependencies && incomplete_dependencies?(task)

      start = start_time(task)
      due = due_time(task)

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
      tasks = tasks_from_section(workspace_name,
                                 project_name,
                                 section_name: section_name,
                                 only_uncompleted: only_uncompleted,
                                 extra_fields: extra_fields)
      tasks.find { |task| task.name == task_name }
    end

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

    private

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil, :unspecified]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks_from_section(workspace_name, project_name,
                           section_name:,
                           only_uncompleted:,
                           extra_fields:)
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

    # @param task [Asana::Resources::Task]
    # @return [Time, nil]
    def start_time(task)
      return @time_class.parse(task.start_at) if task.start_at
      return @time_class.parse(task.start_on) if task.start_on

      nil
    end

    # @param task [Asana::Resources::Task]
    # @return [Time, nil]
    def due_time(task)
      return @time_class.parse(task.due_at) if task.due_at
      return @time_class.parse(task.due_on) if task.due_on

      nil
    end
  end
end
