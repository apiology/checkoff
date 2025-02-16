#!/usr/bin/env ruby
# typed: false

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/reference/timelines

module Checkoff
  # Manages timelines of dependent tasks with dates and milestones
  class Timelines
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param config [Hash,Checkoff::Internal::EnvFallbackConfigLoader]
    # @param workspaces [Checkoff::Workspaces]
    # @param sections [Checkoff::Sections]
    # @param tasks [Checkoff::Tasks]
    # @param portfolios [Checkoff::Portfolios]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config:),
                   sections: Checkoff::Sections.new(config:),
                   tasks: Checkoff::Tasks.new(config:),
                   portfolios: Checkoff::Portfolios.new(config:),
                   clients: Checkoff::Clients.new(config:),
                   client: clients.client)
      @workspaces = workspaces
      @sections = sections
      @tasks = tasks
      @portfolios = portfolios
      @client = client
    end

    # @param task [Asana::Resources::Task]
    # @param limit_to_portfolio_gid [String, nil]
    # @param project_name [String]
    def task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil)
      task_data = @tasks.task_to_h(task)
      # @sg-ignore
      # @type [Array<Hash{String => Hash{String => String}}>]
      memberships_data = task_data.fetch('memberships')
      memberships_data.all? do |membership_data|
        # @type [Hash{String => String}]
        section_data = membership_data.fetch('section')
        section_gid = section_data.fetch('gid')
        section = @sections.section_by_gid(section_gid)
        task_data_dependent_on_previous_section_last_milestone?(task_data, section)
      end
    end

    # @param task [Asana::Resources::Task]
    # @param limit_to_portfolio_name [String, nil]
    def last_task_milestone_depends_on_this_task?(task, limit_to_portfolio_name: nil)
      unless limit_to_portfolio_name.nil?
        limit_to_projects = @portfolios.projects_in_portfolio(@workspaces.default_workspace.name,
                                                              limit_to_portfolio_name)
      end

      all_dependent_task_gids = nil
      task.memberships.all? do |membership_data|
        unless limit_to_portfolio_name.nil?
          project_gid = membership_data.fetch('project').fetch('gid')
          next true unless limit_to_projects.map(&:gid).include? project_gid
        end
        # @type [Hash{String => String}]
        section_data = membership_data.fetch('section')
        # @type [String]
        section_gid = section_data.fetch('gid')

        last_milestone = last_milestone_in_section(section_gid)

        next false if last_milestone.nil?

        next true if last_milestone.gid == task.gid

        all_dependent_task_gids ||= @tasks.all_dependent_tasks(task).map(&:gid)

        all_dependent_task_gids.include? last_milestone.gid
      end
    end

    # @param task [Asana::Resources::Task]
    # @param limit_to_portfolio_name [String, nil]
    def any_milestone_depends_on_this_task?(task, limit_to_portfolio_name: nil)
      unless limit_to_portfolio_name.nil?
        limit_to_projects = @portfolios.projects_in_portfolio(@workspaces.default_workspace.name,
                                                              limit_to_portfolio_name)
      end

      all_dependent_milestones = nil
      task.memberships.all? do |membership_data|
        unless limit_to_portfolio_name.nil?
          project_gid = membership_data.fetch('project').fetch('gid')
          next true unless limit_to_projects.map(&:gid).include? project_gid
        end

        # do this once, but lazily, so we don't have to do it if all
        # projects are excluded
        all_dependent_milestones ||=
          @tasks.all_dependent_tasks(task,
                                     extra_task_fields: ['resource_subtype',
                                                         'memberships.project.gid']).select do |dependent_task|
            dependent_task.resource_subtype == 'milestone'
          end

        all_dependent_milestones.any? do |milestone|
          milestone.memberships.any? do |milestone_membership_data|
            milestone_membership_data.fetch('project').fetch('gid') == project_gid
          end
        end
      end
    end

    # @param section_gid [String]
    #
    # @return [Asana::Resources::Task,nil]
    def last_milestone_in_section(section_gid)
      # @type [Array<Asana::Resources::Task>]
      task_list = @sections.tasks_by_section_gid(section_gid,
                                                 extra_fields: ['resource_subtype']).to_a
      last_task = task_list.last
      last_task&.resource_subtype == 'milestone' ? last_task : nil
    end

    private

    # @param task_data [Hash]
    # @param section [Asana::Resources::Section]
    #
    # @return [Boolean]
    def task_data_dependent_on_previous_section_last_milestone?(task_data, section)
      previous_section = @sections.previous_section(section)
      return false if previous_section.nil?

      previous_section_last_milestone = last_milestone_in_section(previous_section.gid)
      return true if previous_section_last_milestone.nil?

      # @sg-ignore
      # @type [Array<Hash{String => String}>]
      dependencies = task_data.fetch('dependencies')
      return false if dependencies.empty?

      dependencies.any? { |dependency| dependency.fetch('gid') == previous_section_last_milestone.gid }
    end

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./timelines.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # @sg-ignore
        # @type [String]
        # workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # @sg-ignore
        # @type [String]
        # timeline_name = ARGV[1] || raise('Please pass timeline name as second argument')
        # timelines = Checkoff::Timelines.new
        # timeline = timelines.timeline_or_raise(workspace_name, timeline_name)
        # puts "Results: #{timeline}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Timelines.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
