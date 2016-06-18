#!/usr/bin/env ruby

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

    def initialize(sections: Checkoff::Sections.new)
      @sections = sections
    end

    def tasks_minus_sections(tasks)
      @sections.by_section(tasks).values.flatten
    end
  end
end
