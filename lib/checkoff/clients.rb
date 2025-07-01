#!/usr/bin/env ruby
# typed: true

# frozen_string_literal: true

require 'forwardable'
require_relative 'internal/config_loader'
require 'asana'

# https://developers.asana.com/docs/clients

module Checkoff
  # Pulls a configured Asana client object which can be used to access the API
  class Clients
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param config [Checkoff::Internal::EnvFallbackConfigLoader,Hash]
    # @param asana_client_class [Class<Asana::Client>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   asana_client_class: Asana::Client)
      @config = config
      @asana_client_class = asana_client_class
    end

    # @return [Asana::Client]
    def client
      @client ||= @asana_client_class.new do |c|
        c.authentication :access_token, @config.fetch(:personal_access_token)
        c.default_headers 'asana-enable' =>
                          'new_project_templates,new_user_task_lists,new_memberships,new_goal_memberships'
      end
    end

    # bundle exec ./clients.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        clients = Checkoff::Clients.new
        client = clients.client
        puts "Results: #{client}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Clients.run if abs_program_name == __FILE__
# :nocov:
