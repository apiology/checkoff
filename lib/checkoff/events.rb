#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'internal/asana_event_filter'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/reference/events

module Checkoff
  # Methods related to the Asana events / webhooks APIs
  class Events
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    private_constant :MINUTE
    HOUR = MINUTE * 60
    private_constant :HOUR
    DAY = 24 * HOUR
    private_constant :DAY
    REALLY_LONG_CACHE_TIME = HOUR * 1
    private_constant :REALLY_LONG_CACHE_TIME
    LONG_CACHE_TIME = MINUTE * 15
    private_constant :LONG_CACHE_TIME
    SHORT_CACHE_TIME = MINUTE
    private_constant :SHORT_CACHE_TIME

    # @param config [Hash]
    # @param workspaces [Checkoff::Workspaces]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    # @param asana_event_filter_class [Class<Checkoff::Internal::AsanaEventFilter>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config: config),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   asana_event_filter_class: Checkoff::Internal::AsanaEventFilter)
      @workspaces = workspaces
      @client = client
      @asana_event_filter_class = asana_event_filter_class
    end

    # @param filters [Array<Hash>, nil] The filters to match against
    # @param asana_events [Array<Hash>] The events that Asana sent
    #
    # @return [Array<Hash>] The events that should be acted on
    def filter_asana_events(filters, asana_events)
      asana_event_filter = @asana_event_filter_class.new(filters: filters)
      asana_events.select { |event| asana_event_filter.matches?(event) }
    end

    private

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./events.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # @sg-ignore
        # @type [String]
        # workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # @sg-ignore
        # @type [String]
        # event_name = ARGV[1] || raise('Please pass event name as second argument')
        # events = Checkoff::Events.new
        # event = events.event_or_raise(workspace_name, event_name)
        # puts "Results: #{event}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Events.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
