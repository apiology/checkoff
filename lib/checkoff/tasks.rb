#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'sections'
require_relative 'portfolios'
require_relative 'workspaces'
require_relative 'internal/config_loader'
require_relative 'internal/task_timing'
require_relative 'internal/task_hashes'
require_relative 'internal/logging'
require 'asana'

module Checkoff
  # Pull tasks from Asana
  class Tasks
    # @!parse
    #   extend CacheMethod::ClassMethods

    include Logging

    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    # @param config [Hash<Symbol, Object>]
    # @param client [Asana::Client]
    # @param workspaces [Checkoff::Workspaces]
    # @param sections [Checkoff::Sections]
    # @param portfolios [Checkoff::Portfolios]
    # @param custom_fields [Checkoff::CustomFields]
    # @param time_class [Class<Time>]
    # @param date_class [Class<Date>]
    # @param asana_task [Class<Asana::Resources::Task>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config: config).client,
                   workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client),
                   sections: Checkoff::Sections.new(config: config,
                                                    client: client),
                   portfolios: Checkoff::Portfolios.new(config: config,
                                                        client: client),
                   custom_fields: Checkoff::CustomFields.new(config: config,
                                                             client: client),
                   time_class: Time,
                   date_class: Date,
                   asana_task: Asana::Resources::Task)
      @config = config
      @sections = sections
      @time_class = time_class
      @date_class = date_class
      @asana_task = asana_task
      @client = client
      @portfolios = portfolios
      @custom_fields = custom_fields
      @workspaces = workspaces
      @timing = Checkoff::Timing.new(today_getter: date_class, now_getter: time_class)
    end

    # Indicates a task is ready for a person to work on it.  This is
    # subtly different than what is used by Asana to mark a date as
    # red/green!  A task is ready if it is not dependent on an
    # incomplete task and one of these is true:
    #
    # * start is null and due on is today
    # * start is null and due at is before now
    # * start on is today
    # * start at is before now
    #
    # @param task [Asana::Resources::Task]
    # @param period [Symbol<:now_or_before,:this_week>]
    # @param ignore_dependencies [Boolean]
    def task_ready?(task, period: :now_or_before, ignore_dependencies: false)
      return false if !ignore_dependencies && incomplete_dependencies?(task)

      in_period?(task, :ready, period)
    end

    # @param task [Asana::Resources::Task]
    # @param field_name [Symbol,Array]
    # @param period [Symbol<:now_or_before,:this_week>,Array] See Checkoff::Timing#in_period?_
    def in_period?(task, field_name, period)
      # @type [Date,Time,nil]
      task_date_or_time = task_timing.date_or_time_field_by_name(task, field_name)

      timing.in_period?(task_date_or_time, period)
    end

    # @param task [Asana::Resources::Task]
    # @param field_name [Symbol,Array]
    #         :start - start_at or start_on (first set)
    #         :due - due_at or due_on (first set)
    #         :ready - start_at or start_on or due_at or due_on (first set)
    #         :modified - modified_at
    #         [:custom_field, "foo"] - 'Date' custom field type named 'foo'
    #
    # @return [Date, Time, nil]
    def date_or_time_field_by_name(task, field_name)
      task_timing.date_or_time_field_by_name(task, field_name)
    end

    # Pull a specific task by name
    #
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil, Symbol]
    # @param task_name [String]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    # @sg-ignore
    # @return [Asana::Resources::Task, nil]
    def task(workspace_name, project_name, task_name,
             section_name: :unspecified,
             only_uncompleted: true,
             extra_fields: [])
      # @sg-ignore
      t = tasks(workspace_name,
                project_name,
                section_name: section_name,
                only_uncompleted: only_uncompleted,
                extra_fields: extra_fields)
      t.find { |task| task.name == task_name }
    end
    cache_method :task, SHORT_CACHE_TIME

    # Pull a specific task by GID
    #
    # @param task_gid [String]
    # @param extra_fields [Array<String>]
    # @param only_uncompleted [Boolean]
    #
    # @return [Asana::Resources::Task, nil]
    def task_by_gid(task_gid,
                    extra_fields: [],
                    only_uncompleted: false)
      # @type [Hash]
      options = projects.task_options.fetch(:options, {})
      options[:fields] += extra_fields
      options[:completed_since] = '9999-12-01' if only_uncompleted
      client.tasks.find_by_id(task_gid, options: options)
    end
    cache_method :task_by_gid, SHORT_CACHE_TIME

    # Add a task
    #
    # @param name [String]
    # @param workspace_gid [String]
    # @param assignee_gid [String]
    #
    # @return [Asana::Resources::Task]
    def add_task(name,
                 workspace_gid: @workspaces.default_workspace_gid,
                 assignee_gid: default_assignee_gid)
      @asana_task.create(client,
                         assignee: assignee_gid,
                         workspace: workspace_gid, name: name)
    end

    # Return user-accessible URL for a task
    #
    # @param task [Asana::Resources::Task]
    #
    # @return [String] end-user URL to the task in question
    def url_of_task(task)
      "https://app.asana.com/0/0/#{task.gid}/f"
    end

    # True if any of the task's dependencies are marked incomplete
    #
    # Include 'dependencies.gid' in extra_fields of task passed in.
    #
    # @param task [Asana::Resources::Task]
    def incomplete_dependencies?(task)
      # Avoid a redundant fetch.  Unfortunately, Ruby SDK allows
      # dependencies to be fetched along with other attributes--but
      # then doesn't use it and does another HTTP GET!  At least this
      # way we can skip the extra HTTP GET in the common case when
      # there are no dependencies.
      #
      # https://github.com/Asana/ruby-asana/issues/125

      # @sg-ignore
      # @type [Enumerable<Asana::Resources::Task>, nil]
      dependencies = task.instance_variable_get(:@dependencies) || []

      dependencies.any? do |parent_task_info|
        # the real bummer though is that asana doesn't let you fetch
        # the completion status of dependencies, so we need to do this
        # regardless:
        parent_task_gid = parent_task_info.fetch('gid')

        parent_task = task_by_gid(parent_task_gid, only_uncompleted: false)
        parent_task.completed_at.nil?
      end
    end

    # @param task [Asana::Resources::Task]
    # @param extra_task_fields [Array<String>]
    #
    # @return [Array<Hash>]
    def all_dependent_tasks(task, extra_task_fields: [])
      dependent_tasks = []
      # See note above - same applies as does in @dependencies
      #
      # @type [Array<Hash>]
      dependents = task.instance_variable_get(:@dependents) || []
      dependents.each do |dependent_task_hash_or_obj|
        # seems like if we ever .inspect the task, it stashes the task
        # object instead of the hash.  Try to avoid this - but maybe we
        # need to convert if it does happen.
        raise 'Found dependent task object!' if dependent_task_hash_or_obj.is_a?(Asana::Resources::Task)

        dependent_task_hash = dependent_task_hash_or_obj

        dependent_task = task_by_gid(dependent_task_hash.fetch('gid'),
                                     only_uncompleted: true,
                                     extra_fields: ['dependents'] + extra_task_fields)
        debug { "#{task.name} has dependent task #{dependent_task.name}" }
        unless dependent_task.nil?
          dependent_tasks << dependent_task
          dependent_tasks += all_dependent_tasks(dependent_task)
        end
      end
      dependent_tasks
    end

    # Builds on the standard API representation of an Asana task with some
    # convenience keys:
    #
    # <regular keys from API response>
    # +
    # unwrapped:
    #  membership_by_section_gid: Hash<String, Hash (membership)>
    #  membership_by_project_gid: Hash<String, Hash (membership)>
    #  membership_by_project_name: Hash<String, Hash (membership)>
    # task: String (name)
    #
    # @param task [Asana::Resources::Task]
    #
    # @return [Hash]
    def task_to_h(task)
      task_hashes.task_to_h(task)
    end

    # @param task_data [Hash]
    #
    # @return [Asana::Resources::Task]
    def h_to_task(task_data)
      task_hashes.h_to_task(task_data, client: client)
    end

    # True if the task is in a project which is in the given portfolio
    #
    # @param task [Asana::Resources::Task]
    # @param portfolio_name [String]
    # @param workspace_name [String]
    def in_portfolio_named?(task,
                            portfolio_name,
                            workspace_name: @workspaces.default_workspace.name)
      portfolio_projects = @portfolios.projects_in_portfolio(workspace_name, portfolio_name)
      task.memberships.any? do |membership|
        project_gid = membership.fetch('project').fetch('gid')
        portfolio_projects.any? do |portfolio_project|
          portfolio_project.gid == project_gid
        end
      end
    end

    # @return [Hash]
    def as_cache_key
      {}
    end

    private

    # @return [Checkoff::Internal::TaskTiming]
    def task_timing
      @task_timing ||= Checkoff::Internal::TaskTiming.new(time_class: @time_class, date_class: @date_class,
                                                          client: client,
                                                          custom_fields: custom_fields)
    end

    # @return [Checkoff::Internal::TaskHashes]
    def task_hashes
      @task_hashes ||= Checkoff::Internal::TaskHashes.new
    end

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil, Symbol<:unspecified>]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks(workspace_name, project_name,
              only_uncompleted:, extra_fields:, section_name: :unspecified)
      if section_name == :unspecified
        project = projects.project_or_raise(workspace_name, project_name)
        projects.tasks_from_project(project,
                                    only_uncompleted: only_uncompleted,
                                    extra_fields: extra_fields)
      else
        @sections.tasks(workspace_name, project_name, section_name,
                        only_uncompleted: only_uncompleted,
                        extra_fields: extra_fields)
      end
    end
    cache_method :tasks, SHORT_CACHE_TIME

    # @return [Asana::Client]
    attr_reader :client

    # @return [Checkoff::Timing]
    attr_reader :timing

    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields

    # @return [Checkoff::Projects]
    def projects
      @projects ||= @sections.projects
    end

    # @sg-ignore
    # @return [String]
    def default_assignee_gid
      @config.fetch(:default_assignee_gid)
    end
  end
end
