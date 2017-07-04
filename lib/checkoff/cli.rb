#!/usr/bin/env ruby

# frozen_string_literal: true
require 'ostruct'
require 'dalli'
require 'cache_method'
require_relative 'workspaces'
require_relative 'projects'
require_relative 'tasks'
require_relative 'sections'

module Checkoff
  # Provide ability for CLI to pull Asana items
  class CLI
    attr_reader :sections, :stderr

    def initialize(workspaces: Checkoff::Workspaces.new,
                   projects: Checkoff::Projects.new,
                   sections: Checkoff::Sections.new(projects: projects),
                   tasks: Checkoff::Tasks.new,
                   stderr: STDERR,
                   kernel: Kernel)
      @workspaces = workspaces
      @projects = projects
      @sections = sections
      @tasks = tasks
      @kernel = kernel
      @stderr = stderr
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

    def quickadd(workspace_name, task_name)
      workspace = @workspaces.workspace_by_name(workspace_name)
      @tasks.add_task(task_name,
                      workspace_id: workspace.id)
    end

    def validate_args!(args)
      return unless args.length < 2 || !%w(view quickadd).include?(args[0])

      output_help
      exit(1)
    end

    def parse_args(args)
      validate_args!(args)
      mode = args[0]
      subargs = OpenStruct.new
      if mode == 'view'
        subargs.workspace = args[1]
        subargs.project = args[2]
        subargs.section = args[3]
      elsif mode == 'quickadd'
        subargs.workspace = args[1]
        subargs.task_name = args[2]
      else
        raise
      end
      [mode, subargs]
    end

    def output_help
      stderr.puts 'View tasks:'
      stderr.puts "  #{$PROGRAM_NAME} view workspace project [section]"
      stderr.puts "  #{$PROGRAM_NAME} quickadd workspace task_name"
      stderr.puts
      stderr.puts "'project' can be set to a project name, or :my_tasks, " \
                  ':my_tasks_upcoming, :my_tasks_new, or :my_tasks_today'
    end

    def run(args)
      command, subargs = parse_args(args)
      if command == 'view'
        project = subargs.project
        project = project[1..-1].to_sym if project.start_with? ':'
        section = subargs.section
        if section.nil?
          run_on_project(subargs.workspace, project)
        else
          run_on_section(subargs.workspace, project, subargs.section)
        end
      elsif command == 'quickadd'
        quickadd(subargs.workspace, subargs.task_name)
      else
        raise
      end
    end
  end
end
