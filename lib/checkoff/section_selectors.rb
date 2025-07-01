#!/usr/bin/env ruby
# typed: true

# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require_relative 'internal/config_loader'
require_relative 'internal/section_selector_evaluator'
require_relative 'workspaces'
require_relative 'clients'

module Checkoff
  # Filter lists of sections using declarative selectors.
  class SectionSelectors
    MINUTE = 60
    HOUR = MINUTE * 60
    DAY = 24 * HOUR
    REALLY_LONG_CACHE_TIME = HOUR * 1
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE

    # @param config [Hash<Symbol, Object>,Checkoff::Internal::EnvFallbackConfigLoader]
    # @param workspaces [Checkoff::Workspaces]
    # @param sections [Checkoff::Sections]
    # @param custom_fields [Checkoff::CustomFields]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config:),
                   sections: Checkoff::Sections.new(config:),
                   custom_fields: Checkoff::CustomFields.new(config:),
                   clients: Checkoff::Clients.new(config:),
                   client: clients.client)
      @workspaces = workspaces
      @sections = sections
      @custom_fields = custom_fields
      @client = client
    end

    # @param [Asana::Resources::Section] section
    # @param [Array<(Symbol, Array)>] section_selector Filter based on
    #        section details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    # @return [Boolean]
    def filter_via_section_selector(section, section_selector)
      # @sg-ignore
      evaluator = SectionSelectorEvaluator.new(section:, sections:, custom_fields:,
                                               client:)
      evaluator.evaluate(section_selector)
    end

    private

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Checkoff::Sections]
    attr_reader :sections

    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./section_selectors.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # workspace_name = ARGV[0] || raise('Please pass workspace name as first argument')
        # section_selector_name = ARGV[1] || raise('Please pass section_selector name as second argument')
        # section_selectors = Checkoff::SectionSelectors.new
        # section_selector = section_selectors.section_selector_or_raise(workspace_name, section_selector_name)
        # puts "Results: #{section_selector}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::SectionSelectors.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
