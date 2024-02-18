# frozen_string_literal: true

module Checkoff
  module Internal
    # Builds on the standard API representation of an Asana project with some
    # convenience keys.
    class ProjectHashes
      # @param _deps [Hash]
      def initialize(_deps = {}); end

      # @param project_obj [Asana::Resources::Project]
      # @param project [String, Symbol<:not_specified, :my_tasks>]
      #
      # @return [Hash]
      def project_to_h(project_obj, project: :not_specified)
        project = project_obj.name if project == :not_specified
        project_hash = { **project_obj.to_h, 'project' => project }
        project_hash['unwrapped'] = {}
        unwrap_custom_fields(project_hash)
        project_hash
      end

      private

      # @param project_hash [Hash]
      # @return [void]
      def unwrap_custom_fields(project_hash)
        # @sg-ignore
        # @type [Array<Hash>,nil]
        custom_fields = project_hash.fetch('custom_fields', nil)

        return if custom_fields.nil?

        unwrapped_custom_fields = custom_fields.group_by do |cf|
          cf['name']
        end.transform_values(&:first)
        project_hash['unwrapped']['custom_fields'] = unwrapped_custom_fields
      end
    end
  end
end
