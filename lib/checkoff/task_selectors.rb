#!/usr/bin/env ruby
# typed: false

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require 'json'
require_relative 'internal/config_loader'
require_relative 'internal/task_selector_evaluator'
require_relative 'tasks'

module Checkoff
  # Filter lists of tasks using declarative selectors.
  class TaskSelectors
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @sg-ignore
    # @param [Hash,Checkoff::Internal::EnvFallbackConfigLoader] config
    # @param [Asana::Client] client
    # @param [Checkoff::Tasks] tasks
    # @param [Checkoff::Timelines] timelines
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config:).client,
                   tasks: Checkoff::Tasks.new(config:,
                                              client:),
                   timelines: Checkoff::Timelines.new(config:,
                                                      client:),
                   custom_fields: Checkoff::CustomFields.new(config:,
                                                             client:))
      @config = config
      @tasks = tasks
      @timelines = timelines
      @custom_fields = custom_fields
    end

    # @param [Asana::Resources::Task] task
    # @param [Array<(Symbol, Array)>] task_selector Filter based on
    #        task details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    # @return [Boolean]
    def filter_via_task_selector(task, task_selector)
      evaluator = TaskSelectorEvaluator.new(task:, tasks:, timelines:,
                                            custom_fields:)
      evaluator.evaluate(task_selector)
    end

    private

    # @return [Checkoff::Tasks]
    attr_reader :tasks

    # @return [Checkoff::Timelines]
    attr_reader :timelines

    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields

    # bundle exec ./task_selectors.rb
    # :nocov:
    class << self
      # @sg-ignore
      # @return [String]
      def project_name
        ARGV[1] || raise('Please pass project name to pull tasks from as first argument')
      end

      # @sg-ignore
      # @return [String]
      def workspace_name
        ARGV[0] || raise('Please pass workspace name as first argument')
      end

      # @return [Array]
      def task_selector
        task_selector_json = ARGV[2] || raise('Please pass task_selector in JSON form as third argument')
        JSON.parse(task_selector_json)
      end

      # @return [void]
      def run
        require 'checkoff/projects'

        task_selectors = Checkoff::TaskSelectors.new
        extra_fields = ['custom_fields']
        projects = Checkoff::Projects.new
        project = projects.project_or_raise(workspace_name, project_name)
        raw_tasks = projects.tasks_from_project(project, extra_fields:)
        tasks = raw_tasks.filter { |task| task_selectors.filter_via_task_selector(task, task_selector) }
        # avoid n+1 queries generating the full task formatting
        puts JSON.pretty_generate(tasks.map(&:to_h))
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::TaskSelectors.run if abs_program_name == __FILE__
# :nocov:
