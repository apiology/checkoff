# frozen_string_literal: true

require 'forwardable'

module Checkoff
  # Query different subtasks of Asana tasks
  class Subtasks
    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config: config))
      @projects = projects
    end

    # pulls a Hash of subtasks broken out by section
    def by_section(tasks)
      current_section = nil
      by_section = {}
      tasks.each do |task|
        current_section, by_section = file_task_by_section(current_section,
                                                           by_section, task)
      end
      by_section
    end

    # Returns all subtasks, including section headers
    def raw_subtasks(task)
      task.subtasks(projects.task_options)
    end
    cache_method :raw_subtasks, LONG_CACHE_TIME

    private

    attr_reader :projects

    def file_task_by_section(current_section, by_section, task)
      if task.name =~ /:$/
        current_section = task.name
        by_section[current_section] = []
      else
        by_section[current_section] ||= []
        by_section[current_section] << task
      end
      [current_section, by_section]
    end
  end
end
