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

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   projects: Checkoff::Projects.new(config: config),
                   sections: Checkoff::Sections.new(config: config,
                                                    projects: projects),
                   tasks: Checkoff::Tasks.new(config: config),
                   stderr: $stderr,
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
                      workspace_gid: workspace.gid)
    end

    def validate_args!(args)
      return unless args.length < 2 || !%w[view quickadd].include?(args[0])

      output_help
      exit(1)
    end

    def parse_view_args(subargs, args)
      subargs.workspace = args[1]
      subargs.project = args[2]
      subargs.section = args[3]
    end

    def parse_quickadd_args(subargs, args)
      subargs.workspace = args[1]
      subargs.task_name = args[2]
    end

    def parse_args(args)
      mode = args[0]
      subargs = OpenStruct.new
      case mode
      when 'view'
        parse_view_args(subargs, args)
      when 'quickadd'
        parse_quickadd_args(subargs, args)
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
                  ":my_tasks_upcoming, :my_tasks_new, or :my_tasks_today"
    end

    def view(workspace_name, project_name, section_name)
      project_name = project_name[1..-1].to_sym if project_name.start_with? ':'
      if section_name.nil?
        run_on_project(workspace_name, project_name)
      else
        run_on_section(workspace_name, project_name, section_name)
      end
    end

    def run(args)
      validate_args!(args)
      command, subargs = parse_args(args)
      case command
      when 'view'
        view(subargs.workspace, subargs.project, subargs.section)
      when 'quickadd'
        quickadd(subargs.workspace, subargs.task_name)
      else
        raise
      end
    end
  end
end
