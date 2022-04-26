# frozen_string_literal: true

require 'forwardable'
require_relative 'projects'
require_relative 'workspaces'
require_relative 'clients'
require_relative 'my_tasks'

module Checkoff
  # Query different sections of Asana projects
  class Sections
    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    attr_reader :projects, :workspaces, :time, :my_tasks

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config: config),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   time: Time)
      @projects = projects
      @workspaces = workspaces
      @my_tasks = Checkoff::MyTasks.new(config: config, projects: projects)
      @client = client
      @time = time
    end

    # Returns a list of Asana API section objects for a given project
    def sections_or_raise(workspace_name, project_name)
      project = project_or_raise(workspace_name, project_name)
      client.sections.get_sections_for_project(project_gid: project.gid)
    end

    # Given a workspace name and project name, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    def tasks_by_section(workspace_name, project_name)
      project = project_or_raise(workspace_name, project_name)
      if project_name == :my_tasks
        my_tasks.tasks_by_section_for_my_tasks(project)
      else
        tasks_by_section_for_project(project)
      end
    end
    cache_method :tasks_by_section, SHORT_CACHE_TIME

    # XXX: Rename to section_tasks
    #
    # Pulls task objects from a specified section
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
    def section_task_names(workspace_name, project_name, section_name)
      tasks = tasks(workspace_name, project_name, section_name)
      tasks.map(&:name)
    end
    cache_method :section_task_names, SHORT_CACHE_TIME

    def section_or_raise(workspace_name, project_name, section_name)
      section = section(workspace_name, project_name, section_name)
      if section.nil?
        valid_sections = sections_or_raise(workspace_name, project_name).map(&:name)

        raise "Could not find section #{section_name} under project #{project_name} " \
              "under workspace #{workspace_name}.  Valid sections: #{valid_sections}"
      end
      section
    end
    cache_method :section_or_raise, LONG_CACHE_TIME

    private

    attr_reader :client

    # Given a project object, pull all tasks, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    def tasks_by_section_for_project(project)
      # print("project: #{project}")
      raw_tasks = projects.tasks_from_project(project)
      # print("raw_tasks[0]: #{raw_tasks[0]}")
      active_tasks = projects.active_tasks(raw_tasks)
      by_section(active_tasks, project.gid)
    end

    # Given a list of tasks, pull a Hash of tasks with section name -> task list
    def by_section(tasks, project_gid)
      by_section = {}
      tasks.each do |task|
        file_task_by_section(by_section, task, project_gid)
      end
      by_section
    end
    cache_method :by_section, LONG_CACHE_TIME

    def file_task_by_section(by_section, task, project_gid)
      membership = task.memberships.find { |m| m['project']['gid'] == project_gid }
      raise "Could not find task in project_gid #{project_gid}: #{task}" if membership.nil?

      current_section = membership['section']['name']
      current_section = nil if ['(no section)', 'Untitled section'].include?(current_section)
      by_section[current_section] ||= []
      by_section[current_section] << task
    end

    def project_or_raise(workspace_name, project_name)
      project = projects.project(workspace_name, project_name)
      if project.nil?
        raise "Could not find project #{project_name} " \
              "under workspace #{workspace_name}"
      end
      project
    end

    def section(workspace_name, project_name, section_name)
      sections = sections_or_raise(workspace_name, project_name)
      sections.find { |section| section.name.chomp(':') == section_name.chomp(':') }
    end
  end
end
