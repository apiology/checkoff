#!/usr/bin/env ruby

# frozen_string_literal: true

require 'date'
require 'time'
require 'active_support'
# require 'active_support/time'
require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

module Checkoff
  # Common vocabulary for managing time and time periods
  class Timing
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param today_getter [Class<Date>]
    def initialize(today_getter: Date)
      @today_getter = today_getter
    end

    # @param date [Date]
    # @param period [Symbol<:indefinite>]
    def in_period?(date, period)
      return this_week?(date) if period == :this_week

      return true if period == :indefinite

      raise "Teach me how to handle period #{period.inspect}"
    end

    private

    # @param date [Date]
    def this_week?(date)
      today = @today_getter.today

      # Beginning of this week (assuming week starts on Sunday)
      beginning_of_week = today - today.wday

      # End of this week (assuming week ends on Saturday)
      end_of_week = beginning_of_week + 6

      date >= beginning_of_week && date <= end_of_week
    end

    # bundle exec ./time.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        time = Checkoff::Timing.new
        # time = time.time_or_raise(workspace_name, time_name)
        puts "Results: #{time}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Timing.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
