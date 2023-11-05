#!/usr/bin/env ruby

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'workspaces'
require_relative 'clients'

# https://developers.asana.com/reference/portfolios

module Checkoff
  # Pull portfolios from Asana
  class Portfolios
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param config [Hash]
    # @param workspaces [Checkoff::Workspaces]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   clients: Checkoff::Clients.new(config: config),
                   client: clients.client,
                   workspaces: Checkoff::Workspaces.new(config: config, client: client))
      @workspaces = workspaces
      @client = client
    end

    # @param workspace_name [String]
    # @param portfolio_name [String]
    #
    # @return [Asana::Resources::Portfolio]
    def portfolio_or_raise(workspace_name, portfolio_name)
      portfolio_obj = portfolio(workspace_name, portfolio_name)
      raise "Could not find portfolio #{portfolio_name} under workspace #{workspace_name}." if portfolio_obj.nil?

      portfolio_obj
    end
    cache_method :portfolio_or_raise, LONG_CACHE_TIME

    # @param workspace_name [String]
    # @param portfolio_name [String]
    #
    # @sg-ignore
    # @return [Asana::Resources::Portfolio,nil]
    def portfolio(workspace_name, portfolio_name)
      workspace = workspaces.workspace_or_raise(workspace_name)
      me = client.users.me
      portfolio_objs = client.portfolios.find_all(workspace: workspace.gid,
                                                  owner: me.gid)
      # @type [Asana::Resources::Portfolio, nil]
      portfolio_objs.find { |portfolio_obj| portfolio_obj.name == portfolio_name }
    end
    cache_method :portfolio, LONG_CACHE_TIME

    # Pull a specific portfolio by gid
    #
    # @param portfolio_gid [String]
    # @param extra_fields [Array<String>]
    #
    # @return [Asana::Resources::Portfolio, nil]
    def portfolio_by_gid(portfolio_gid,
                         extra_fields: [])
      options = {
        fields: ['name'],
      }
      options[:fields] += extra_fields
      client.portfolios.find_by_id(portfolio_gid, options: options)
    end
    cache_method :portfolio_by_gid, SHORT_CACHE_TIME

    # @param workspace_name [String]
    # @param portfolio_name [String]
    # @param extra_project_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Project>]
    def projects_in_portfolio(workspace_name, portfolio_name,
                              extra_project_fields: [])
      portfolio = portfolio_or_raise(workspace_name, portfolio_name)
      projects_in_portfolio_obj(portfolio)
    end
    cache_method :projects_in_portfolio, LONG_CACHE_TIME

    # @param portfolio [Asana::Resources::Portfolio]
    # @param extra_project_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Project>]
    def projects_in_portfolio_obj(portfolio, extra_project_fields: [])
      options = {
        fields: ['name'],
      }
      options[:fields] += extra_project_fields
      client.portfolios.get_items_for_portfolio(portfolio_gid: portfolio.gid, options: options)
    end

    private

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./portfolios.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # @sg-ignore
        # @type [String]
        workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # @sg-ignore
        # @type [String]
        portfolio_name = ARGV[1] || raise('Please pass portfolio name as second argument')
        portfolios = Checkoff::Portfolios.new
        portfolio = portfolios.portfolio_or_raise(workspace_name, portfolio_name)
        puts "Results: #{portfolio}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Portfolios.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
