# frozen_string_literal: true

require 'forwardable'
require 'cache_method'
require 'checkoff/internal/config_loader'
require 'checkoff/internal/logging'
require 'checkoff/internal/asana_event_enrichment'
require 'checkoff/workspaces'
require 'checkoff/clients'

module Checkoff
  module Internal
    # Add useful info (like resource task names) into an Asana
    # event/event filters/webhook subscription for human consumption
    class AsanaEventEnrichment
      # @param config [Hash]
      # @param workspaces [Checkoff::Workspaces]
      # @param tasks [Checkoff::Tasks]
      # @param sections [Checkoff::Sections]
      # @param projects [Checkoff::Projects]
      # @param resources [Checkoff::Resources]
      # @param clients [Checkoff::Clients]
      # @param client [Asana::Client]
      # @param asana_event_enrichment [Checkoff::Internal::AsanaEventEnrichment]
      def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                     workspaces: Checkoff::Workspaces.new(config: config),
                     tasks: Checkoff::Tasks.new(config: config),
                     sections: Checkoff::Sections.new(config: config),
                     projects: Checkoff::Projects.new(config: config),
                     resources: Checkoff::Resources.new(config: config),
                     clients: Checkoff::Clients.new(config: config),
                     client: clients.client)
        @workspaces = workspaces
        @tasks = tasks
        @sections = sections
        @projects = projects
        @resources = resources
        @client = client
      end

      # Add useful info (like resource task names) into an event for
      # human consumption
      #
      # @param asana_event [Hash]
      #
      # @return [Hash]
      def enrich_event(asana_event)
        finer { "Enriching event: #{asana_event}" }
        asana_event = asana_event.dup
        enrich_event_resource!(asana_event)
        enrich_event_parent!(asana_event)
        asana_event
      end

      # @param filter [Hash<String,[String,Array<String>]>]
      #
      # @return [Hash<String,[String,Array<String>]>]
      def enrich_filter(filter)
        filter = filter.dup
        enrich_filter_section!(filter)
        enrich_filter_resource!(filter)
        enrich_filter_parent_gid!(filter)
        filter
      end

      # @param webhook_subscription [Hash] Hash of the request made to
      #   webhook POST endpoint - https://app.asana.com/api/1.0/webhooks
      #   https://developers.asana.com/reference/createwebhook
      #
      # @return [void]
      def enrich_webhook_subscription!(webhook_subscription)
        webhook_subscription&.fetch('filters', nil)&.map! do |filter|
          enrich_filter(filter)
        end
        resource = webhook_subscription&.fetch('resource', nil)
        # @sg-ignore
        name, resource_type = enrich_gid(resource) if resource
        webhook_subscription['checkoff:enriched:name'] = name if name
        webhook_subscription['checkoff:enriched:resource_type'] = resource_type if resource_type
      end

      private

      # Attempt to look up a GID in situations where we don't have a
      # resource type provided, and returns the name of the resource.
      #
      # @param gid [String]
      # @param resource_type [String,nil]
      #
      # @return [Array<([String, nil], [String,nil])>]
      def enrich_gid(gid, resource_type: nil)
        # @sg-ignore
        resource, resource_type = resources.fetch_gid(gid, resource_type: resource_type)
        [resource&.name, resource_type]
      end

      # @param filter [Hash{String => String}]
      #
      # @return [String, nil]
      def enrich_filter_parent_gid!(filter)
        parent_gid = filter['checkoff:parent.gid']
        return unless parent_gid

        # @sg-ignore
        name, resource_type = enrich_gid(parent_gid)
        filter['checkoff:enriched:parent.name'] = name if name
        filter['checkoff:enriched:parent.resource_type'] = resource_type if resource_type
      end

      # @param filter [Hash{String => String}]
      #
      # @return [void]
      def enrich_filter_resource!(filter)
        resource_gid = filter['checkoff:resource.gid']

        return unless resource_gid

        task = tasks.task_by_gid(resource_gid)
        filter['checkoff:enriched:resource.name'] = task.name if task
      end

      # @param filter [Hash{String => [String,Array<String>]}]
      #
      # @return [void]
      def enrich_filter_section!(filter)
        section_gid = filter['checkoff:fetched.section.gid']
        return unless section_gid

        section = sections.section_by_gid(section_gid)
        name = section&.name
        filter['checkoff:enriched:fetched.section.name'] = name if name
      end

      # @param asana_event [Hash{'resource' => Hash}]
      #
      # @return [void]
      def enrich_event_parent!(asana_event)
        # @type [Hash{String => String }]
        parent = asana_event['parent']

        return unless parent

        # @type [String]
        resource_type = parent.fetch('resource_type')
        # @type [String]
        gid = parent.fetch('gid')
        # @sg-ignore
        name, _resource_type = enrich_gid(gid, resource_type: resource_type)
        parent['checkoff:enriched:name'] = name if name

        nil
      end

      # @param asana_event [Hash{'resource' => Hash}]
      #
      # @return [void]
      def enrich_event_resource!(asana_event)
        # @type [Hash{String => String }]
        resource = asana_event['resource']
        # @type [String]
        resource_type = resource.fetch('resource_type')

        # @type [String]
        gid = resource.fetch('gid')

        # @sg-ignore
        name, _resource_type = enrich_gid(gid, resource_type: resource_type)
        resource['checkoff:enriched:name'] = name if name

        nil
      end

      include Logging

      # @return [Checkoff::Projects]
      attr_reader :projects

      # @return [Checkoff::Sections]
      attr_reader :sections

      # @return [Checkoff::Tasks]
      attr_reader :tasks

      # @return [Checkoff::Workspaces]
      attr_reader :workspaces

      # @return [Checkoff::Resources]
      attr_reader :resources

      # @return [Asana::Client]
      attr_reader :client
    end
  end
end
