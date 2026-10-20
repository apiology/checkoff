# typed: true
# frozen_string_literal: true

module Checkoff
  module Internal
    # Asana resources return nil for fields that were not requested via
    # 'fields' / extra_fields; these accessors raise a clear error instead.
    module RequestedFields
      # @param task [Asana::Resources::Task]
      #
      # @return [Array<Hash{String => Hash{String => String}}>]
      def self.memberships_or_raise(task)
        memberships = task.memberships
        if memberships.nil?
          raise "memberships not found on task #{task.gid} - " \
                "did you add 'memberships' in your extra_fields argument?"
        end

        memberships
      end

      # @param section [Asana::Resources::Section]
      #
      # @return [Hash{String => String}]
      def self.section_project_or_raise(section)
        # @type [Hash{String => String}, nil]
        project = section.project
        if project.nil?
          raise "project not found on section #{section.gid} - " \
                "did you add 'project' in your extra_fields argument?"
        end

        project
      end
    end
  end
end
