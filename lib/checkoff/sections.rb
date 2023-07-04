# frozen_string_literal: true

require 'forwardable'
require_relative 'projects'
require_relative 'workspaces'
require_relative 'clients'
require_relative 'my_tasks'

module Checkoff
  # Query different sections of Asana projects
  class Sections
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    # @return [Checkoff::Projects]
    attr_reader :projects

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Class<Time>]
    attr_reader :time

    # @return [Checkoff::MyTasks]
    attr_reader :my_tasks

    # @param config [Hash<Symbol, Object>]
    # @param client [Asana::Client]
    # @param projects [Checkoff::Projects]
    # @param workspaces [Checkoff::Workspaces]
    # @param time [Class<Time>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   projects: Checkoff::Projects.new(config: config,
                                                    client: client),
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client),
                   time: Time)
      @projects = projects
      @workspaces = workspaces
      @my_tasks = Checkoff::MyTasks.new(config: config, projects: projects, client: client)
      @client = client
      @time = time
    end

    # Returns a list of Asana API section objects for a given project
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    #
    # @return [Array<Asana::Resources::Section>]
    def sections_or_raise(workspace_name, project_name)
      project = project_or_raise(workspace_name, project_name)
      # @sg-ignore
      client.sections.get_sections_for_project(project_gid: project.gid)
    end
    cache_method :sections_or_raise, SHORT_CACHE_TIME

    # Given a workspace name and project name, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param extra_fields [Array<String>]
    # @return [Hash{[String, nil] => Array<Asana::Resources::Task>}]
    def tasks_by_section(workspace_name, project_name, extra_fields: [])
      raise ArgumentError, 'Provided nil workspace name' if workspace_name.nil?
      raise ArgumentError, 'Provided nil project name' if project_name.nil?

      project = project_or_raise(workspace_name, project_name)
      if project_name == :my_tasks
        my_tasks.tasks_by_section_for_my_tasks(project, extra_fields: extra_fields)
      else
        tasks_by_section_for_project(project, extra_fields: extra_fields)
      end
    end

    # XXX: Rename to section_tasks
    #
    # Pulls task objects from a specified section
    #
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Array<Asana::Resources::Task>]
    def tasks(workspace_name, project_name, section_name,
              only_uncompleted: true,
              extra_fields: [])
      section = section_or_raise(workspace_name, project_name, section_name)
      options = projects.task_options
      options[:options][:fields] += extra_fields
      options[:completed_since] = '9999-12-01' if only_uncompleted
      client.tasks.get_tasks(section: section.gid,
                             **options)
    end
    cache_method :tasks, SHORT_CACHE_TIME

    # Pulls just names of tasks from a given section.
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    #
    # @return [Array<String>]
    def section_task_names(workspace_name, project_name, section_name)
      task_array = tasks(workspace_name, project_name, section_name)
      task_array.map(&:name)
    end
    cache_method :section_task_names, SHORT_CACHE_TIME

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    #
    # @sg-ignore
    # @return [Asana::Resources::Section]
    def section_or_raise(workspace_name, project_name, section_name)
      s = section(workspace_name, project_name, section_name)
      if s.nil?
        valid_sections = sections_or_raise(workspace_name, project_name).map(&:name)

        raise "Could not find section #{section_name} under project #{project_name} " \
              "under workspace #{workspace_name}.  Valid sections: #{valid_sections}"
      end
      s
    end
    cache_method :section_or_raise, LONG_CACHE_TIME

    private

    # @return [Asana::Client]
    attr_reader :client

    # Given a project object, pull all tasks, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    # @param project [Asana::Resources::Project]
    # @param extra_fields [Array<String>]
    # @return [Hash<[String,nil], Array<Asana::Resources::Task>>]
    def tasks_by_section_for_project(project, extra_fields: [])
      raw_tasks = projects.tasks_from_project(project, extra_fields: extra_fields)
      active_tasks = projects.active_tasks(raw_tasks)
      by_section(active_tasks, project.gid)
    end

    # @param name [String]
    # @return [String, nil]
    def section_key(name)
      inbox_section_names = ['(no section)', 'Untitled section', 'Inbox']
      return nil if inbox_section_names.include?(name)

      name
    end

    # Given a list of tasks, pull a Hash of tasks with section name -> task list
    # @param tasks [Array<Asana::Resources::Task>]
    # @param project_gid [String]
    # @return [Hash<[String,nil], Array<Asana::Resources::Task>>]
    def by_section(tasks, project_gid)
      by_section = {}
      # @sg-ignore
      sections = client.sections.get_sections_for_project(project_gid: project_gid)
      sections.each { |section| by_section[section_key(section.name)] = [] }
      tasks.each { |task| file_task_by_section(by_section, task, project_gid) }
      by_section
    end
    cache_method :by_section, LONG_CACHE_TIME

    # @param by_section [Hash{[String, nil] => Array<Asana::Resources::Task>}]
    # @param task [Asana::Resources::Task]
    # @param project_gid [String]
    # @return [void]
    def file_task_by_section(by_section, task, project_gid)
      # @type [Array<Hash>]
      membership = task.memberships.find { |m| m['project']['gid'] == project_gid }
      raise "Could not find task in project_gid #{project_gid}: #{task}" if membership.nil?

      # @type [String, nil]
      current_section = section_key(membership['section']['name'])

      # @sg-ignore
      by_section.fetch(current_section) << task
    end

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @return [Asana::Resources::Project]
    def project_or_raise(workspace_name, project_name)
      raise ArgumentError, 'Provide nil project_name' if project_name.nil?

      project = projects.project(workspace_name, project_name)
      if project.nil?
        raise "Could not find project #{project_name} " \
              "under workspace #{workspace_name}"
      end
      project
    end

    # @sg-ignore
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    # @return [Asana::Resources::Section, nil]
    def section(workspace_name, project_name, section_name)
      sections = sections_or_raise(workspace_name, project_name)
      sections.find { |section| section_key(section.name)&.chomp(':') == section_name&.chomp(':') }
    end
  end
end
