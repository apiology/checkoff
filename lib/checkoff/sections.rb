# frozen_string_literal: true

require 'forwardable'

module Checkoff
  # Query different sections of Asana projects
  # rubocop:disable Metrics/ClassLength
  class Sections
    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    attr_reader :projects, :workspaces, :time

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config: config),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   time: Time)
      @projects = projects
      @workspaces = workspaces
      @time = time
    end

    # Given a project object, pull all tasks, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    def tasks_by_section_for_project(project)
      raw_tasks = projects.tasks_from_project(project)
      active_tasks = projects.active_tasks(raw_tasks)
      by_section(active_tasks, project.gid)
    end

    # Given a workspace name and project name, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    def tasks_by_section(workspace_name, project_name)
      project = project_or_raise(workspace_name, project_name)
      tasks_by_section_for_project(project)
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
      # asana-0.10.3 gem doesn't support per_page - not sure if API
      # itself does
      options.delete(:per_page)
      options[:options][:fields] += extra_fields
      client.tasks.get_tasks_for_section(section_gid: section.gid,
                                         **options).to_a
    end
    cache_method :tasks, SHORT_CACHE_TIME

    # Pulls just names of tasks from a given section.
    def section_task_names(workspace_name, project_name, section_name)
      tasks = tasks(workspace_name, project_name, section_name)
      if tasks.nil?
        by_section = tasks_by_section(workspace_name, project_name)
        desc = "#{workspace_name} | #{project_name} | #{section_name}"
        raise "Could not find task names for #{desc}.  " \
              "Valid sections: #{by_section.keys}"
      end
      tasks.map(&:name)
    end
    cache_method :section_task_names, SHORT_CACHE_TIME

    # returns if a task's due field is at or before the current date/time
    def task_due?(task)
      if task.due_at
        Time.parse(task.due_at) <= time.now
      elsif task.due_on
        Date.parse(task.due_on) <= time.today
      else
        true # set a due date if you don't want to do this now
      end
    end

    private

    def_delegators :@projects, :client

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
      current_section = nil if current_section == '(no section)'
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
      project = project_or_raise(workspace_name, project_name)
      sections = client.sections.get_sections_for_project(project_gid: project.gid)
      sections.find { |section| section.name.chomp(':') == section_name.chomp(':') }
    end

    def section_or_raise(workspace_name, project_name, section_name)
      section = section(workspace_name, project_name, section_name)
      if section.nil?
        raise "Could not find section #{section_name} under project #{project_name} " \
              "under workspace #{workspace_name}"
      end
      section
    end

    def project_task_names(workspace_name, project_name)
      by_section = tasks_by_section(workspace_name, project_name)
      by_section.flat_map do |section_name, tasks|
        task_names = tasks.map(&:name)
        if section_name.nil?
          task_names
        else
          [section_name, task_names]
        end
      end
    end
    cache_method :project_task_names, SHORT_CACHE_TIME
  end
  # rubocop:enable Metrics/ClassLength
end
