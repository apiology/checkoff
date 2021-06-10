#!/usr/bin/env ruby

# frozen_string_literal: true

require 'ostruct'
require 'dalli'
require 'gli'
require 'cache_method'
require_relative 'workspaces'
require_relative 'projects'
require_relative 'tasks'
require_relative 'sections'

module Checkoff
  # CLI subcommand that shows tasks in JSON form
  class ViewSubcommand
    def initialize(workspace_name, project_name, section_name,
                   task_name,
                   config: Checkoff::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config: config),
                   sections: Checkoff::Sections.new(config: config,
                                                    projects: projects),
                   tasks: Checkoff::Tasks.new(config: config,
                                              sections: sections),
                   stderr: $stderr)
      @workspace_name = workspace_name
      @stderr = stderr
      validate_and_assign_project_name(project_name)
      @section_name = section_name
      @task_name = task_name
      @sections = sections
      @tasks = tasks
    end

    def run
      if section_name.nil?
        run_on_project(workspace_name, project_name)
      elsif task_name.nil?
        run_on_section(workspace_name, project_name, section_name)
      else
        run_on_task(workspace_name, project_name, section_name, task_name)
      end
    end

    private

    def validate_and_assign_project_name(project_name)
      @project_name = if project_name.start_with? ':'
                        project_name[1..].to_sym
                      else
                        project_name
                      end
    end

    def run_on_project(workspace, project)
      tasks_by_section =
        sections.tasks_by_section(workspace, project)
      tasks_by_section.update(tasks_by_section) do |_key, tasks|
        tasks_to_hash(tasks)
      end
      tasks_by_section.to_json
    end

    def run_on_section(workspace, project, section)
      section = nil if section == ''
      tasks = sections.tasks(workspace, project, section) || []
      tasks_to_hash(tasks).to_json
    end

    def run_on_task(workspace, project, section, task_name)
      section = nil if section == ''
      task = tasks.task(workspace, project, task_name, section_name: section)
      task_to_hash(task).to_json
    end

    def task_to_hash(task)
      task_out = {
        name: task.name,
      }
      if task.due_on
        task_out[:due] = task.due_on
      elsif task.due_at
        task_out[:due] = task.due_at
      end
      task_out
    end

    def tasks_to_hash(tasks)
      tasks.map { |task| task_to_hash(task) }
    end

    attr_reader :workspace_name, :project_name, :section_name, :task_name, :sections, :tasks, :stderr
  end

  # CLI subcommand that creates a task
  class QuickaddSubcommand
    def initialize(workspace_name, task_name,
                   config: Checkoff::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   tasks: Checkoff::Tasks.new(config: config))
      @workspace_name = workspace_name
      @task_name = task_name
      @workspaces = workspaces
      @tasks = tasks
    end

    def run
      workspace = @workspaces.workspace_by_name(workspace_name)
      @tasks.add_task(task_name,
                      workspace_gid: workspace.gid)
    end

    private

    attr_reader :workspace_name, :task_name
  end

  # Provide ability for CLI to pull Asana items
  class CheckoffGLIApp
    extend GLI::App

    program_desc 'Command-line client for Asana (unofficial)'

    subcommand_option_handling :normal
    arguments :strict

    desc 'Add a short task to Asana'
    arg 'workspace'
    arg 'task_name'
    command :quickadd do |c|
      c.action do |_global_options, _options, args|
        workspace_name = args.fetch(0)
        task_name = args.fetch(1)

        QuickaddSubcommand.new(workspace_name, task_name).run
      end
    end

    desc 'Output representation of Asana tasks'
    arg 'workspace'
    arg 'project'
    arg 'section', :optional
    arg 'task_name', :optional
    command :view do |c|
      c.action do |_global_options, _options, args|
        workspace_name = args.fetch(0)
        project_name = args.fetch(1)
        section_name = args[2]
        task_name = args[3]

        puts ViewSubcommand.new(workspace_name, project_name, section_name, task_name).run
      end
    end
  end
end
