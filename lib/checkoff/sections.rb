# frozen_string_literal: true
module Checkoff
  # Query different sections of Asana projects
  class Sections
    MINUTE = 60
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    attr_reader :projects, :time

    def initialize(projects: Checkoff::Projects.new,
                   time: Time)
      @projects = projects
      @time = time
    end

    def client
      @projects.client
    end

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

    def by_section(tasks)
      current_section = nil
      by_section = {}
      tasks.each do |task|
        current_section, by_section = file_task_by_section(current_section,
                                                           by_section, task)
      end
      by_section
    end
    cache_method :by_section, LONG_CACHE_TIME

    def tasks_by_section_for_project(project)
      raw_tasks = projects.tasks_from_project(project)
      active_tasks = projects.active_tasks(raw_tasks)
      by_section(active_tasks)
    end

    def tasks_by_section_for_project_and_assignee_status(project,
                                                         assignee_status)
      raw_tasks = projects.tasks_from_project(project)
      by_assignee_status =
        projects.active_tasks(raw_tasks)
                .group_by(&:assignee_status)
      active_tasks = by_assignee_status[assignee_status]
      by_section(active_tasks)
    end

    def project_or_raise(workspace_name, project_name)
      project = projects.project(workspace_name, project_name)
      if project.nil?
        raise "Could not find project #{project_name} " \
              "under workspace #{workspace_name}"
      end
      project
    end

    def tasks_by_section(workspace_name, project_name)
      project = project_or_raise(workspace_name, project_name)
      if project_name == :my_tasks_new
        tasks_by_section_for_project_and_assignee_status(project, 'inbox')
      elsif project_name == :my_tasks_today
        tasks_by_section_for_project_and_assignee_status(project, 'today')
      elsif project_name == :my_tasks_upcoming
        tasks_by_section_for_project_and_assignee_status(project, 'upcoming')
      else
        tasks_by_section_for_project(project)
      end
    end
    cache_method :tasks_by_section, SHORT_CACHE_TIME

    # XXX: Rename to section_tasks
    def tasks(workspace_name, project_name, section_name)
      tasks_by_section(workspace_name, project_name)[section_name]
    end
    cache_method :tasks, SHORT_CACHE_TIME

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

    # Returns all subtasks, including section headers
    def raw_subtasks(task)
      task.subtasks(projects.task_options)
    end
    cache_method :raw_subtasks, LONG_CACHE_TIME

    def task_due?(task)
      if task.due_at
        Time.parse(task.due_at) <= time.now
      elsif task.due_on
        Date.parse(task.due_on) <= time.today
      else
        true # set a due date if you don't want to do this now
      end
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
end
