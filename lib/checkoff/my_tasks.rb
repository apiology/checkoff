# frozen_string_literal: true

require 'forwardable'
require_relative 'projects'
require_relative 'workspaces'
require_relative 'clients'

module Checkoff
  # Query different sections of Asana 'My Tasks' projects
  class MyTasks
    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    attr_reader :projects

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config: config))
      @config = config
      @projects = projects
    end

    # Given a 'My Tasks' project object, pull all tasks, then provide
    # a Hash of tasks with section name -> task list of the
    # uncompleted tasks.
    def tasks_by_section_for_my_tasks(project, extra_fields: [])
      raw_tasks = projects.tasks_from_project(project,
                                              extra_fields: extra_fields + ['assignee_section.name'])
      active_tasks = projects.active_tasks(raw_tasks)
      by_my_tasks_section(active_tasks)
    end

    # Given a list of tasks in 'My Tasks', pull a Hash of tasks with
    # section name -> task list
    def by_my_tasks_section(tasks)
      by_section = {}
      tasks.each do |task|
        assignee_section = task.assignee_section
        current_section = assignee_section.name
        by_section[current_section] ||= []
        by_section[current_section] << task
      end
      by_section
    end
  end
end
