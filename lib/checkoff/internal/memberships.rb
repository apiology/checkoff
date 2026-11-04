# typed: true
# frozen_string_literal: true

module Checkoff
  module Internal
    # Reads the project/section memberships of an Asana task
    class Memberships
      # Asana returns nil for memberships unless they were requested via
      # 'fields' / extra_fields; raise a clear error instead.
      #
      # @param task [Asana::Resources::Task]
      #
      # @return [Array<Hash{String => Hash{String => String}}>]
      def memberships_or_raise(task)
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
