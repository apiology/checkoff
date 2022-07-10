# frozen_string_literal: true

require 'forwardable'
require_relative 'internal/config_loader'
require_relative 'projects'

module Checkoff
  # Query different subtasks of Asana tasks
  class Subtasks
    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config: config))
      @projects = projects
    end

    # True if all subtasks of the task are completed
    def all_subtasks_completed?(task)
      raw_subtasks = raw_subtasks(task)
      active_subtasks = @projects.active_tasks(raw_subtasks)
      # anything left should be a section
      active_subtasks.all? { |subtask| subtask_section?(subtask) }
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
      task_options = projects.task_options
      task_options[:options][:fields] << 'is_rendered_as_separator'
      task.subtasks(task_options)
    end
    cache_method :raw_subtasks, SHORT_CACHE_TIME

    # True if the subtask passed in represents a section in the subtasks
    #
    # Note: expect this to be removed in a future version, as Asana is
    # expected to move to the new-style way of representing sections
    # as memberships with a separate API within a task.
    def subtask_section?(subtask)
      subtask.is_rendered_as_separator
    end

    private

    attr_reader :projects

    def file_task_by_section(current_section, by_section, task)
      if subtask_section?(task)
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
