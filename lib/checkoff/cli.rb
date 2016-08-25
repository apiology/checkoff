#!/usr/bin/env ruby

# frozen_string_literal: true
require 'ostruct'
require 'dalli'
require 'cache_method'
require_relative 'projects'
require_relative 'tasks'
require_relative 'sections'

module Checkoff
  # Provide ability for CLI to pull Asana items
  class CLI
    attr_reader :sections, :stderr

    def initialize(sections: Checkoff::Sections.new,
                   stderr: STDERR,
                   kernel: Kernel)
      @sections = sections
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

    def validate_args!(args)
      mode, _workspace, project, _section = args
      return unless project.nil? || mode != 'view'

      output_help
      exit(1)
    end

    def parse_args(args)
      validate_args!(args)
      args[1..-1]
    end

    def output_help
      stderr.puts 'View tasks:'
      stderr.puts "  #{$PROGRAM_NAME} view workspace project [section]"
      stderr.puts
      stderr.puts "'project' can be set to a project name, or :my_tasks, " \
                  ':my_tasks_upcoming, :my_tasks_new, or :my_tasks_today'
    end

    def run(args)
      workspace, project, section = parse_args(args)
      project = project[1..-1].to_sym if project.start_with? ':'
      if section.nil?
        run_on_project(workspace, project)
      else
        run_on_section(workspace, project, section)
      end
    end
  end
end
