#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'sections'
require_relative 'workspaces'
require 'asana'

module Checkoff
  # Pull tasks from Asana
  class Tasks
    MINUTE = 60
    # @sg-ignore
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR
    # @sg-ignore
    LONG_CACHE_TIME = MINUTE * 15
    # @sg-ignore
    SHORT_CACHE_TIME = MINUTE * 5

    # @param client [Asana::Client]
    # @param workspaces [Checkoff::Workspaces]
    # @param time_class [Class<Time>]
    # @param sections [Checkoff::Sections]
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

    def task_ready?(task)
      return false if incomplete_dependencies?(task)

      due = due_time(task)

      return true if due.nil?

      due < @time_class.now
    end

    # Pull a specific task by name
    # @return [Asana::Resources::Task, nil]
    def task(workspace_name, project_name, task_name,
             section_name: :unspecified,
             only_uncompleted: true,
             extra_fields: [])
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

    # Return an end-user URL to the task in question
    def url_of_task(task)
      "https://app.asana.com/0/0/#{task.gid}/f"
    end

    private

    # @return [Array<Asana::Resources::Task>]
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
    def due_time(task)
      return @time_class.parse(task.due_at) if task.due_at
      return @time_class.parse(task.due_on) if task.due_on

      nil
    end

    def incomplete_dependencies?(task)
      # Avoid a redundant fetch.  Unfortunately, Ruby SDK allows
      # dependencies to be fetched along with other attributes--but
      # then doesn't use it and does another HTTP GET!  At least this
      # way we can skip the extra HTTP GET in the common case when
      # there are no dependencies.
      #
      # https://github.com/Asana/ruby-asana/issues/125

      # @sg-ignore
      # @type [Array<Asana::Resources::Task>, nil]
      already_fetched_dependencies = task.instance_variable_get(:@dependencies)
      # @sg-ignore
      return false unless already_fetched_dependencies.nil? || already_fetched_dependencies.size.positive?

      task.dependencies.any? do |parent_task_info|
        parent_task_gid = parent_task_info.gid
        parent_task = @asana_task.find_by_id(client, parent_task_gid,
                                             options: { fields: ['completed'] })
        !parent_task.completed
      end
    end
  end
end
