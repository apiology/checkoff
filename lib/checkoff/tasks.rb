#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'sections'

module Checkoff
  # Pull things from 'my tasks' in Asana
  class Tasks
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    def initialize(config: Checkoff::ConfigLoader.load(:asana),
                   sections: Checkoff::Sections.new)
      @config = config
      @sections = sections
    end

    def client
      @sections.client
    end

    def tasks_minus_sections(tasks)
      @sections.by_section(tasks).values.flatten
    end

    def add_task(name,
                 workspace_id: default_workspace_id,
                 assignee_id: default_assignee_id)
      Asana::Resources::Task.create(client,
                                    assignee: assignee_id,
                                    workspace: workspace_id, name: name)
    end

    def default_assignee_id
      @config[:default_assignee_id]
    end
  end
end
