# typed: true
# frozen_string_literal: true

require_relative 'logging'

module Checkoff
  module Internal
    # Uses an enhanced version of Asana event filter configuration
    #
    # See https://developers.asana.com/reference/createwebhook | body
    # params | data | filters | add object for a general description of the scheme.
    #
    # Additional supported filter keys:
    #
    # * 'checkoff:parent.gid' - requires that the 'gid' key in the 'parent' object
    #   match the given value
    class AsanaEventFilter
      include Logging

      # @param filters [Array<Hash>, nil] The filters to match against
      # @param clients [Checkoff::Clients]
      # @param tasks [Checkoff::Tasks]
      # @param client [Asana::Client]
      def initialize(filters:,
                     clients: Checkoff::Clients.new,
                     tasks: Checkoff::Tasks.new,
                     client: clients.client)
        @filters = filters
        @client = client
        @tasks = tasks
      end

      # @param asana_event [Hash] The event that Asana sent
      def matches?(asana_event)
        logger.debug { "Filtering using #{@filters.inspect}" }
        return true if @filters.nil?

        failures = []

        @filters.any? do |filter|
          filter_matches = filter_matches_asana_event?(filter, asana_event, failures)
          logger.debug { "Filter #{filter.inspect} matched? #{filter_matches} against event #{asana_event.inspect}" }
          unless filter_matches
            logger.debug do
              "Filter #{filter.inspect} failed to match event #{asana_event.inspect} because of #{failures.inspect}"
            end
            failures << filter
          end
          filter_matches
        end
      end

      private

      # @param filter [Hash]
      # @param asana_event [Hash]
      # @param failures [Array<String>]
      #
      # @sg-ignore
      # @return [Boolean]
      def filter_matches_asana_event?(filter, asana_event, failures)
        # @param key [String]
        # @param value [String, Array<String>]
        filter.all? do |key, value|
          matches = asana_event_matches_filter_item?(key, value, asana_event)
          failures << "#{key.inspect} = #{value.inspect}" unless matches

          matches
        end
      end

      # @param key [String]
      # @param value [String, Array<String>]
      # @param asana_event [Hash]
      #
      # @sg-ignore
      # @return [Boolean]
      def asana_event_matches_filter_item?(key, value, asana_event)
        case key
        when 'resource_type'
          asana_event.fetch('resource', {})['resource_type'] == value
        when 'resource_subtype'
          asana_event.fetch('resource', {})['resource_subtype'] == value
        when 'action'
          asana_event['action'] == value
        when 'fields'
          value.include? asana_event.fetch('change', {})['field']
        when 'checkoff:parent.gid'
          asana_event.fetch('parent', {})['gid'] == value
        when 'checkoff:resource.gid'
          asana_event.fetch('resource', {})['gid'] == value
        when 'checkoff:fetched.section.gid'
          fields = ['memberships.project.gid', 'memberships.project.name',
                    'memberships.section.name', 'assignee', 'assignee_section']
          task = uncached_fetch_task(key, asana_event, fields)
          return false if task.nil?

          task_data = @tasks.task_to_h(task)
          task_data.fetch('unwrapped').fetch('membership_by_section_gid').keys.include?(value)
        when 'checkoff:fetched.parent_task.gid'
          fields = ['parent']
          task = uncached_fetch_task(key, asana_event, fields)
          return false if task.nil?

          task.parent&.fetch('gid', nil) == value
        when 'checkoff:fetched.completed'
          fields = ['completed_at']
          task = uncached_fetch_task(key, asana_event, fields)
          return false if task.nil?

          task_completed = !task.completed_at.nil?
          task_completed == value
        else
          raise "Unknown filter key #{key}"
        end
      end

      # @param key [String]
      # @param asana_event [Hash]
      # @param fields [Array<String>]
      #
      # @return [Asana::Resources::Task,nil]
      def uncached_fetch_task(key, asana_event, fields)
        # @type [Hash{String => String}]
        # @sg-ignore
        resource = asana_event.fetch('resource')
        # @type [String]
        resource_type = resource.fetch('resource_type')
        unless resource_type == 'task'
          raise "Teach me how to check #{key.inspect} on resource type #{resource_type.inspect}"
        end

        task_gid = resource.fetch('gid')
        options = {
          fields:,
        }
        @client.tasks.find_by_id(task_gid, options:)
      rescue Asana::Errors::NotFound
        nil
      end
    end
  end
end
