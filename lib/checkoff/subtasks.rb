# typed: false
# frozen_string_literal: true

require 'forwardable'
require_relative 'internal/config_loader'
require_relative 'projects'

module Checkoff
  # Query different subtasks of Asana tasks
  class Subtasks
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    # @param config [Hash,Checkoff::Internal::EnvFallbackConfigLoader]
    # @param projects [Checkoff::Projects]
    # @param clients [Checkoff::Clients]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config:),
                   clients: Checkoff::Clients.new(config:))
      @projects = projects
      @client = clients.client
    end

    # True if all subtasks of the task are completed
    #
    # @param task [Asana::Resources::Task]
    def all_subtasks_completed?(task)
      rs = raw_subtasks(task)
      active_subtasks = @projects.active_tasks(rs)
      # anything left should be a section
      active_subtasks.all? { |subtask| subtask_section?(subtask) }
    end

    # pulls a Hash of subtasks broken out by section
    #
    # @param tasks [Enumerable<Asana::Resources::Task>]
    #
    # @return [Hash<[nil,String], Enumerable<Asana::Resources::Task>>]
    def by_section(tasks)
      current_section = nil
      by_section = { nil => [] }
      tasks.each do |task|
        # @sg-ignore
        current_section, by_section = file_task_by_section(current_section,
                                                           by_section, task)
      end
      by_section
    end

    # Returns all subtasks, including section headers
    #
    # @param task [Asana::Resources::Task]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def raw_subtasks(task)
      subtasks_by_gid(task.gid)
    end
    cache_method :raw_subtasks, LONG_CACHE_TIME

    # Pull a specific task by GID
    #
    # @param task_gid [String]
    # @param extra_fields [Array<String>]
    # @param only_uncompleted [Boolean]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def subtasks_by_gid(task_gid,
                        extra_fields: [],
                        only_uncompleted: true)
      # @type [Hash]
      all_options = projects.task_options(extra_fields: extra_fields + %w[is_rendered_as_separator],
                                          only_uncompleted:)
      options = all_options.fetch(:options, {})
      client.tasks.get_subtasks_for_task(task_gid:,
                                         # per_page: 100, # stub doesn't have this arg available
                                         options:)
    end
    cache_method :subtasks_by_gid, LONG_CACHE_TIME

    # True if the subtask passed in represents a section in the subtasks
    #
    # Note: expect this to be removed in a future version, as Asana is
    # expected to move to the new-style way of representing sections
    # as memberships with a separate API within a task.
    #
    # @param subtask [Asana::Resources::Task]
    def subtask_section?(subtask)
      subtask.is_rendered_as_separator
    end

    private

    # @return [Checkoff::Projects]
    attr_reader :projects

    # @return [Asana::Client]
    attr_reader :client

    # @param current_section [String,nil]
    # @param by_section [Hash]
    # @param task [Asana::Resources::Task]
    #
    # @return [Array<(String, Hash)>]
    def file_task_by_section(current_section, by_section, task)
      if subtask_section?(task)
        current_section = task.name
        raise "More than one section named #{task.name}" if by_section.key? task.name

        by_section[current_section] = []
      else
        by_section[current_section] << task
      end
      [current_section, by_section]
    end
  end
end
