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

    def_delegators :@projects, :client

    def file_task_by_section(by_section, task, project_gid)
      membership = task.memberships.find { |m| m['project']['gid'] == project_gid }
      raise "Could not find task in project_gid #{project_gid}: #{task}" if membership.nil?

      current_section = membership['section']['name']
      current_section = nil if current_section == '(no section)'
      by_section[current_section] ||= []
      by_section[current_section] << task
    end

    def by_section(tasks, project_gid)
      by_section = {}
      tasks.each do |task|
        file_task_by_section(by_section, task, project_gid)
      end
      by_section
    end
    cache_method :by_section, LONG_CACHE_TIME

    def legacy_tasks_by_section_for_project(project)
      raw_tasks = projects.tasks_from_project(project)
      active_tasks = projects.active_tasks(raw_tasks)
      legacy_by_section(active_tasks)
    end

    def tasks_by_section_for_project(project)
      raw_tasks = projects.tasks_from_project(project)
      active_tasks = projects.active_tasks(raw_tasks)
      by_section(active_tasks, project.gid)
    end

    def legacy_file_task_by_section(current_section, by_section, task)
      if task.name =~ /:$/
        current_section = task.name
        by_section[current_section] = []
      else
        by_section[current_section] ||= []
        by_section[current_section] << task
      end
      [current_section, by_section]
    end

    def legacy_by_section(tasks)
      current_section = nil
      by_section = {}
      tasks.each do |task|
        current_section, by_section =
          legacy_file_task_by_section(current_section, by_section, task)
      end
      by_section
    end

    def legacy_tasks_by_section_for_project_and_assignee_status(project,
                                                                assignee_status)
      raw_tasks = projects.tasks_from_project(project)
      by_assignee_status =
        projects.active_tasks(raw_tasks)
                .group_by(&:assignee_status)
      active_tasks = by_assignee_status[assignee_status]
      legacy_by_section(active_tasks)
    end

    def project_or_raise(workspace_name, project_name)
      project = projects.project(workspace_name, project_name)
      if project.nil?
        raise "Could not find project #{project_name} " \
              "under workspace #{workspace_name}"
      end
      project
    end

    def verify_legacy_user_task_list!(workspace_name)
      return unless user_task_list_migrated_to_real_sections?(workspace_name)

      raise NotImplementedError, 'Section-based user task lists not yet supported'
    end

    ASSIGNEE_STATUS_BY_PROJECT_NAME = {
      my_tasks_new: 'inbox',
      my_tasks_today: 'today',
      my_tasks_upcoming: 'upcoming',
    }.freeze

    def user_task_list_by_section(workspace_name, project_name)
      verify_legacy_user_task_list!(workspace_name)

      if project_name == :my_tasks
        legacy_tasks_by_section_for_project(project_name)
      else
        legacy_tasks_by_section_for_project_and_assignee_status(project_name,
                                                                ASSIGNEE_STATUS_BY_PROJECT_NAME.fetch(project_name))
      end
    end

    # rubocop:disable Metrics/MethodLength
    def tasks_by_section(workspace_name, project_name)
      project = project_or_raise(workspace_name, project_name)
      case project_name
      when :my_tasks
        user_task_list_by_section(workspace_name, project_name)
      when :my_tasks_new
        user_task_list_by_section(workspace_name, project_name)
      when :my_tasks_today
        user_task_list_by_section(workspace_name, project_name)
      when :my_tasks_upcoming
        user_task_list_by_section(workspace_name, project_name)
      else
        tasks_by_section_for_project(project)
      end
    end
    cache_method :tasks_by_section, SHORT_CACHE_TIME
    # rubocop:enable Metrics/MethodLength

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

    def user_task_list_migrated_to_real_sections?(workspace_name)
      workspace = workspaces.workspace_by_name(workspace_name)
      result = client.user_task_lists.get_user_task_list_for_user(user_gid: 'me',
                                                                  workspace: workspace.gid)
      result.migration_status != 'not_migrated'
    end

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
  # rubocop:enable Metrics/ClassLength
end
