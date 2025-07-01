# typed: true
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

    # @return [Checkoff::Projects]
    attr_reader :projects

    # @param config [Checkoff::Internal::EnvFallbackConfigLoader,Hash]
    # @param client [Asana::Client]
    # @param projects [Checkoff::Projects]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config:).client,
                   projects: Checkoff::Projects.new(config:,
                                                    client:))
      @config = config
      @client = client
      @projects = projects
    end

    # Given a 'My Tasks' project object, pull all tasks, then provide
    # a Hash of tasks with section name -> task list of the
    # uncompleted tasks.
    #
    # @param project [Asana::Resources::Project]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    # @return [Hash{String => Enumerable<Asana::Resources::Task>}]
    def tasks_by_section_for_my_tasks(project,
                                      only_uncompleted: true,
                                      extra_fields: [])
      raw_tasks = projects.tasks_from_project(project,
                                              only_uncompleted:,
                                              extra_fields: extra_fields + ['assignee_section.name'])
      active_tasks = projects.active_tasks(raw_tasks)
      by_my_tasks_section(active_tasks, project.gid)
    end

    # @param name [String]
    # @return [String, nil]
    def section_key(name)
      return nil if name == 'Recently assigned'

      name
    end

    # Given a list of tasks in 'My Tasks', pull a Hash of tasks with
    # section name -> task list
    #
    # @param tasks [Enumerable<Asana::Resources::Task>]
    # @param project_gid [String]
    # @return [Hash{String => Enumerable<Asana::Resources::Task>}]
    def by_my_tasks_section(tasks, project_gid)
      by_section = {}
      sections = client.sections.get_sections_for_project(project_gid:,
                                                          options: { fields: ['name'] })
      sections.each_entry { |section| by_section[section_key(section.name)] = [] }
      tasks.each do |task|
        assignee_section = task.assignee_section
        current_section = section_key(assignee_section.name)
        by_section[current_section] ||= []
        by_section[current_section] << task
      end
      by_section
    end

    private

    # @return [Asana::Client]
    attr_reader :client
  end
end
