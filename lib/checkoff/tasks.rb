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

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   sections: Checkoff::Sections.new(config: config),
                   asana_task: Asana::Resources::Task)
      @config = config
      @sections = sections
      @asana_task = asana_task
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
                @sections.tasks(workspace_name, project_name, section_name)
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

    private

    def client
      @sections.client
    end

    def projects
      @projects ||= @sections.projects
    end

    def tasks_minus_sections(tasks)
      @sections.by_section(tasks).values.flatten
    end

    def default_assignee_gid
      @config.fetch(:default_assignee_gid)
    end
  end
end
