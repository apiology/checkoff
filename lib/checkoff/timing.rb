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
    # @param now_getter [Class<Time>]
    def initialize(today_getter: Date,
                   now_getter: Time)
      @today_getter = today_getter
      @now_getter = now_getter
    end

    # @param date_or_time [Date,Time,nil]
    # @param period [Symbol,Array<(Symbol,Integer)>]
    #
    #        Valid values: :this_week, :now_or_before, :indefinite, [:less_than_n_days_ago, Integer]
    def in_period?(date_or_time, period)
      return this_week?(date_or_time) if period == :this_week

      return true if period == :indefinite

      return now_or_before?(date_or_time) if period == :now_or_before

      if period.is_a?(Array)
        # @sg-ignore
        # @type [Symbol]
        period_name = period.first
        args = period[1..]

        return compound_in_period?(date_or_time, period_name, *args)
      end

      raise "Teach me how to handle period #{period.inspect}"
    end

    private

    # @param date_or_time [Date,Time,nil]
    # @param num_days [Integer]
    def greater_than_or_equal_to_n_days_from_today?(date_or_time, num_days)
      return false if date_or_time.nil?

      date = date_or_time.to_date

      # @sg-ignore
      n_days_from_today = @today_getter.today + num_days
      # @sg-ignore
      date >= n_days_from_today
    end

    # @param date_or_time [Date,Time,nil]
    # @param num_days [Integer]
    def greater_than_or_equal_to_n_days_from_now?(date_or_time, num_days)
      return false if date_or_time.nil?

      date_or_time >= n_days_from_now(num_days)
    end

    # @param date_or_time [Date,Time,nil]
    # @param num_days [Integer]
    def less_than_n_days_ago?(date_or_time, num_days)
      return false if date_or_time.nil?

      date = date_or_time.to_date

      # @sg-ignore
      n_days_ago = @today_getter.today - num_days
      # @sg-ignore
      date < n_days_ago
    end

    # @param date_or_time [Date,Time,nil]
    # @param num_days [Integer]
    def less_than_n_days_from_now?(date_or_time, num_days)
      return false if date_or_time.nil?

      date_or_time < n_days_from_now(num_days)
    end

    # @param date_or_time [Date,Time,nil]
    def this_week?(date_or_time)
      return true if date_or_time.nil?

      today = @today_getter.today

      # Beginning of this week (assuming week starts on Sunday)
      beginning_of_week = today - today.wday

      # End of this week (assuming week ends on Saturday)
      end_of_week = beginning_of_week + 6

      date = date_or_time.to_date

      date >= beginning_of_week && date <= end_of_week
    end

    # @param date_or_time [Date,Time,nil]
    def now_or_before?(date_or_time)
      return true if date_or_time.nil?

      date_or_time.to_time < @now_getter.now
    end

    # @param num_days [Integer]
    #
    # @return [Time]
    def n_days_from_now(num_days)
      (@now_getter.now + (num_days * 24 * 60 * 60))
    end

    # @param date_or_time [Date,Time,nil]
    # @param beginning_num_days_from_now [Integer,nil]
    # @param end_num_days_from_now [Integer,nil]
    def between_relative_days?(date_or_time, beginning_num_days_from_now, end_num_days_from_now)
      start_time = n_days_from_now(beginning_num_days_from_now || -99_999)
      end_time = n_days_from_now(end_num_days_from_now || 99_999)

      return false if date_or_time.nil?

      if date_or_time.is_a?(Time)
        date_or_time > start_time && date_or_time <= end_time
      else
        date_or_time > start_time.to_date && date_or_time <= end_time.to_date
      end
    end

    # @param date_or_time [Date,Time,nil]
    # @param period_name [Symbol]
    # @param args [Object]
    def compound_in_period?(date_or_time, period_name, *args)
      # @sg-ignore
      return less_than_n_days_ago?(date_or_time, *args) if period_name == :less_than_n_days_ago

      return less_than_n_days_from_now?(date_or_time, *args) if period_name == :less_than_n_days_from_now

      if period_name == :greater_than_or_equal_to_n_days_from_now
        return greater_than_or_equal_to_n_days_from_now?(date_or_time, *args)
      end

      if period_name == :greater_than_or_equal_to_n_days_from_today
        return greater_than_or_equal_to_n_days_from_today?(date_or_time, *args)
      end

      # @sg-ignore
      return between_relative_days?(date_or_time, *args) if period_name == :between_relative_days

      raise "Teach me how to handle period [#{period_name.inspect}, #{args.map(&:inspect).join(', ')}]"
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
