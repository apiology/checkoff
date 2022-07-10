#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'sections'

module Checkoff
  # Pull tasks from Asana
  class Tasks
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   sections: Checkoff::Sections.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   time_class: Time,
                   asana_task: Asana::Resources::Task)
      @config = config
      @sections = sections
      @time_class = time_class
      @asana_task = asana_task
      @client = client
    end

    def task_ready?(task)
      return false if incomplete_dependencies?(task)

      due = due_time(task)

      return true if due.nil?

      due < @time_class.now
    end

    # Pull a specific task by name
    def task(workspace_name, project_name, task_name,
             section_name: :unspecified,
             only_uncompleted: true)
      project = projects.project(workspace_name, project_name)
      tasks = if section_name == :unspecified
                projects.tasks_from_project(project,
                                            only_uncompleted: only_uncompleted)
              else
                @sections.tasks(workspace_name, project_name, section_name,
                                only_uncompleted: only_uncompleted)
              end
      tasks.find { |task| task.name == task_name }
    end

    def add_task(name,
                 workspace_gid: default_workspace_gid,
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

    attr_reader :client

    def projects
      @projects ||= @sections.projects
    end

    def default_assignee_gid
      @config.fetch(:default_assignee_gid)
    end

    def due_time(task)
      return @time_class.parse(task.due_at) if task.due_at
      return @time_class.parse(task.due_on) if task.due_on

      nil
    end

    def incomplete_dependencies?(task)
      # Avoid a reundant fetch.  Unfortunately, Ruby SDK allows
      # dependencies to be fetched along with other attributes--but
      # then doesn't use it and does another HTTP GET!  At least this
      # way we can skip the extra HTTP GET in the common case when
      # there are no dependencies.
      #
      # https://github.com/Asana/ruby-asana/issues/125
      already_fetched_dependencies = task.instance_variable_get(:@dependencies)
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
