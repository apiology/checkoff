# typed: true
# frozen_string_literal: true

module Checkoff
  module Internal
    # Builds on the standard API representation of an Asana project with some
    # convenience keys.
    class ProjectHashes
      # @param _deps [Hash]
      def initialize(_deps = {}); end

      # The two custom_fields entries below hold the same records: the top-level
      # array is what Asana returns, and unwrapped re-keys those records by name.
      #
      # @param project_obj [Asana::Resources::Project]
      # @param project [String, :not_specified, :my_tasks, nil] - a String is a
      #   project name
      #
      # @return [Hash{"project" => String, Symbol, nil} &
      #   Hash{"gid" => String} &
      #   Hash{"name" => String} &
      #   Hash{"custom_fields" => Array<
      #     Hash{"gid" => String} &
      #     Hash{"name" => String} &
      #     Hash{"display_value" => String, nil} &
      #     Hash{"number_value" => Float, Integer, nil} &
      #     Hash{"text_value" => String, nil} &
      #     Hash{"enum_value" => Hash{String => String}, nil}
      #   >, nil} &
      #   Hash{"unwrapped" => Hash{"custom_fields" => Hash{String =>
      #     Hash{"gid" => String} &
      #     Hash{"name" => String} &
      #     Hash{"display_value" => String, nil} &
      #     Hash{"number_value" => Float, Integer, nil} &
      #     Hash{"text_value" => String, nil} &
      #     Hash{"enum_value" => Hash{String => String}, nil}
      #   }}}]
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
        # @type [Array<Hash{String => Object}>,nil]
        custom_fields = project_hash['custom_fields']

        return if custom_fields.nil?

        unwrapped_custom_fields = custom_fields.group_by do |cf|
          cf['name']
        end.transform_values(&:first)
        project_hash['unwrapped']['custom_fields'] = unwrapped_custom_fields
      end
    end
  end
end
