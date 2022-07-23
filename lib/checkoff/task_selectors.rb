#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require 'json'
require_relative 'internal/config_loader'
require_relative 'internal/task_selector_evaluator'

# https://developers.asana.com/docs/task-selectors

module Checkoff
  # Filter lists of tasks using declarative selectors.
  class TaskSelectors
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana))
      @config = config
    end

    # @param [Hash<Symbol, Object>] task_selector Filter based on
    #        description.  Examples: {tag: 'foo'} {:not {tag: 'foo'} (:tag 'foo')
    def filter_via_task_selector(task, task_selector)
      evaluator = TaskSelectorEvaluator.new(task: task)
      evaluator.evaluate(task_selector)
    end

    # bundle exec ./task_selectors.rb
    # :nocov:
    class << self
      def project_name
        ARGV[1] || raise('Please pass project name to pull tasks from as first argument')
      end

      def workspace_name
        ARGV[0] || raise('Please pass workspace name as first argument')
      end

      def task_selector
        task_selector_json = ARGV[2] || raise('Please pass task_selector in JSON form as third argument')
        JSON.parse(task_selector_json)
      end

      def run
        require 'checkoff/projects'

        task_selectors = Checkoff::TaskSelectors.new
        extra_fields = ['custom_fields']
        projects = Checkoff::Projects.new
        project = projects.project_or_raise(workspace_name, project_name)
        raw_tasks = projects.tasks_from_project(project, extra_fields: extra_fields)
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
