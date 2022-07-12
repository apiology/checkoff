#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require 'json'
require_relative 'internal/config_loader'

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

    def initialize(_deps = {}); end

    # @param [Hash<Symbol, Object>] task_selector Filter based on
    #        description.  Examples: {tag: 'foo'} {:not {tag: 'foo'} (:tag 'foo')
    def filter_via_task_selector(task, task_selector)
      return true if task_selector == []

      return !filter_via_task_selector(task, task_selector.fetch(1)) if fn?(task_selector, :not)

      return filter_via_task_selector(task, task_selector.fetch(1)).nil? if fn?(task_selector, :nil?)

      return contains_tag?(task, task_selector.fetch(1)) if fn?(task_selector, :tag)

      return custom_field_value(task, task_selector.fetch(1)) if fn?(task_selector, :custom_field_value)

      raise "Syntax issue trying to handle #{task_selector}"
    end

    private

    def contains_tag?(task, tag_name)
      task.tags.map(&:name).include? tag_name
    end

    def custom_field_value(task, custom_field_name)
      custom_field = task.custom_fields.find { |field| field.fetch('name') == custom_field_name }
      return nil if custom_field.nil?

      custom_field['display_value']
    end

    def fn?(object, fn_name)
      object.is_a?(Array) && !object.empty? && [fn_name, fn_name.to_s].include?(object[0])
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
        extra_fields = []
        projects = Checkoff::Projects.new
        project = projects.project(workspace_name, project_name)
        raw_tasks = projects.tasks_from_project(project, extra_fields: extra_fields)
        tasks = raw_tasks.filter { |task| task_selectors.filter_via_task_selector(task, task_selector) }
        puts "Results: #{tasks}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::TaskSelectors.run if abs_program_name == __FILE__
# :nocov:
