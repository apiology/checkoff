#!/usr/bin/env ruby
# typed: true

# frozen_string_literal: true

require 'ostruct'
require 'gli'
require 'cache_method'
require_relative 'workspaces'
require_relative 'projects'
require_relative 'tasks'
require_relative 'sections'

module Checkoff
  # Move tasks from one place to another
  class MvSubcommand
    # @param from_workspace_arg [Symbol,String]
    # @param from_project_arg [Symbol,String]
    # @param from_section_arg [nil,String]
    # @return [void]
    def validate_and_assign_from_location(from_workspace_arg, from_project_arg, from_section_arg)
      if from_workspace_arg == :default_workspace
        # Figure out what to do here - we accept a default
        # workspace gid and default workspace_gid arguments elsewhere.
        # however, there are undefaulted workspace_name arguments as
        # well...
        raise NotImplementedError, 'Not implemented: Teach me how to look up default workspace name'
      end

      @from_workspace_name = from_workspace_arg
      @from_project_name = project_arg_to_name(from_project_arg)
      @from_section_name = from_section_arg
    end

    # @param to_project_arg [Symbol,String]
    #
    # @return [String,Symbol]
    def create_to_project_name(to_project_arg)
      if to_project_arg == :source_project
        from_project_name
      else
        project_arg_to_name(to_project_arg)
      end
    end

    # @param to_section_arg [Symbol,String,nil]
    #
    # @return [nil,String]
    def create_to_section_name(to_section_arg)
      if to_section_arg == :source_section
        from_section_name
      else
        to_section_arg
      end
    end

    def validate_and_assign_to_location(to_workspace_arg, to_project_arg, to_section_arg)
      @to_workspace_name = to_workspace_arg
      @to_workspace_name = from_workspace_name if to_workspace_arg == :source_workspace
      @to_project_name = create_to_project_name(to_project_arg)
      @to_section_name = create_to_section_name(to_section_arg)

      return unless from_workspace_name != to_workspace_name

      raise NotImplementedError, 'Not implemented: Teach me how to move tasks between workspaces'
    end

    def initialize(from_workspace_arg:,
                   from_project_arg:,
                   from_section_arg:,
                   to_workspace_arg:,
                   to_project_arg:,
                   to_section_arg:,
                   config: Checkoff::Internal::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config:),
                   sections: Checkoff::Sections.new(config:),
                   logger: $stderr)
      validate_and_assign_from_location(from_workspace_arg, from_project_arg, from_section_arg)
      validate_and_assign_to_location(to_workspace_arg, to_project_arg, to_section_arg)

      @projects = projects
      @sections = sections
      @logger = logger
    end

    def move_tasks(tasks, to_project, to_section)
      tasks.each do |task|
        # a. check if already in correct project and section (future)
        # b. if not, put it there
        @logger.puts "Moving #{task.name} to #{to_section.name}..."
        task.add_project(project: to_project.gid, section: to_section.gid)
      end
    end

    def fetch_tasks(from_workspace_name, from_project_name, from_section_name)
      if from_section_name == :all_sections
        raise NotImplementedError, 'Not implemented: Teach me how to move all sections of a project'
      end

      sections.tasks(from_workspace_name, from_project_name, from_section_name)
    end

    def run
      # 0. Look up project and section gids
      to_project = projects.project_or_raise(to_workspace_name, to_project_name)
      to_section = sections.section_or_raise(to_workspace_name, to_project_name, to_section_name)

      # 1. Get list of tasks which match
      tasks = fetch_tasks(from_workspace_name, from_project_name, from_section_name)
      # 2. for each task,
      move_tasks(tasks, to_project, to_section)
      # 3. tell the user we're done'
      @logger.puts 'Done moving tasks'
    end

    private

    attr_reader :from_workspace_name, :from_project_name, :from_section_name,
                :to_workspace_name, :to_project_name, :to_section_name,
                :projects, :sections

    def project_arg_to_name(project_arg)
      if project_arg.start_with? ':'
        project_arg[1..].to_sym
      else
        project_arg
      end
    end
  end

  # CLI subcommand that shows tasks in JSON form
  class ViewSubcommand
    def initialize(workspace_name, project_name, section_name,
                   task_name,
                   config: Checkoff::Internal::ConfigLoader.load(:asana),
                   projects: Checkoff::Projects.new(config:),
                   sections: Checkoff::Sections.new(config:,
                                                    projects:),
                   tasks: Checkoff::Tasks.new(config:,
                                              sections:),
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
                   config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config:),
                   tasks: Checkoff::Tasks.new(config:))
      @workspace_name = workspace_name
      @task_name = task_name
      @workspaces = workspaces
      @tasks = tasks
    end

    def run
      workspace = @workspaces.workspace_or_raise(workspace_name)
      @tasks.add_task(task_name,
                      workspace_gid: workspace.gid)
    end

    private

    attr_reader :workspace_name, :task_name
  end

  # Provide ability for CLI to pull Asana items
  class CheckoffGLIApp
    extend ::GLI::App

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

    desc 'Move tasks from one section to another within a project'

    # rubocop:disable Metrics/BlockLength
    command :mv do |c|
      c.flag :from_workspace,
             type: String,
             default_value: :default_workspace,
             desc: 'Workspace to move tasks from'
      c.flag :from_project,
             type: String,
             required: true,
             desc: 'Project to move tasks from'
      c.flag :from_section,
             type: String,
             default_value: :all_sections,
             desc: 'Section to move tasks from'
      c.flag :to_workspace,
             type: String,
             default_value: :source_workspace,
             desc: 'Workspace to move tasks to'
      c.flag :to_project,
             type: String,
             default_value: :source_project,
             desc: 'Section to move tasks to'
      c.flag :to_section,
             type: String,
             default_value: :source_section,
             desc: 'Section to move tasks to'
      c.action do |_global_options, options, _args|
        from_workspace = options.fetch('from_workspace')
        from_project = options.fetch('from_project')
        from_section = options.fetch('from_section')
        to_workspace = options.fetch('to_workspace')
        to_project = options.fetch('to_project')
        to_section = options.fetch('to_section')
        MvSubcommand.new(from_workspace_arg: from_workspace,
                         from_project_arg: from_project,
                         from_section_arg: from_section,
                         to_workspace_arg: to_workspace,
                         to_project_arg: to_project,
                         to_section_arg: to_section).run
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
