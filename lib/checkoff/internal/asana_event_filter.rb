# frozen_string_literal: true

require_relative 'logging'

module Checkoff
  module Internal
    # Uses an enhanced version of Asana event filter configuration
    #
    # See https://developers.asana.com/reference/createwebhook | body
    # params | data | filters for a general description of the scheme.
    #
    # Additional supported filter keys:
    #
    # * 'checkoff:parent.gid' - requires that the 'gid' key in the 'parent' object
    #   match the given value
    class AsanaEventFilter
      include Logging

      # @param filters [Array<Hash>, nil] The filters to match against
      def initialize(filters:)
        @filters = filters
      end

      # @param asana_event [Hash] The event that Asana sent
      def matches?(asana_event)
        logger.debug { "Filtering using #{@filters.inspect}" }
        return true if @filters.nil?

        @filters.any? do |filter|
          out = filter_matches_asana_event?(filter, asana_event)
          logger.debug { "Filter #{filter.inspect} matched? #{out} against event #{asana_event.inspect}" }
          out
        end
      end

      private

      # @param filter [Hash]
      # @param asana_event [Hash]
      #
      # @sg-ignore
      # @return [Boolean]
      def filter_matches_asana_event?(filter, asana_event)
        # @param key [String]
        # @param value [String, Array<String>]
        filter.all? do |key, value|
          asana_event_matches_filter_item?(key, value, asana_event)
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
        else
          raise "Unknown filter key #{key}"
        end
      end
    end
  end
end
