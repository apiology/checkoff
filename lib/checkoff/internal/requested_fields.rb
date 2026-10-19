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
    end
  end
end
