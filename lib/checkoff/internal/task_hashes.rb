# frozen_string_literal: true

module Checkoff
  module Internal
    # Builds on the standard API representation of an Asana task with some
    # convenience keys.
    class TaskHashes
      # @param task [Asana::Resources::Task]
      # @return [Hash]
      def task_to_h(task)
        # @type [Hash]
        task_hash = task.to_h
        task_hash['unwrapped'] = {}
        unwrap_custom_fields(task_hash)
        unwrap_memberships(task_hash)
        task_hash['task'] = task.name
        task_hash
      end

      # @param task_data [Hash]
      # @param client [Asana::Client]
      #
      # @return [Asana::Resources::Task]
      def h_to_task(task_data, client:)
        # copy of task_data without the 'unwrapped' key
        clean_task_data = task_data.dup
        clean_task_data.delete('unwrapped')
        Asana::Resources::Task.new(clean_task_data, client: client)
      end

      private

      # @param task_hash [Hash]
      # @return [void]
      def unwrap_custom_fields(task_hash)
        unwrapped_custom_fields = task_hash.fetch('custom_fields', []).group_by do |cf|
          cf['name']
        end.transform_values(&:first)
        task_hash['unwrapped']['custom_fields'] = unwrapped_custom_fields
      end

      # @param task_hash [Hash]
      # @param resource [String]
      # @param key [String]
      #
      # @return [void]
      def unwrap_membership(task_hash, resource, key)
        # @sg-ignore
        # @type [Array<Hash>]
        memberships = task_hash.fetch('memberships', [])
        # @sg-ignore
        # @type [Hash]
        unwrapped = task_hash.fetch('unwrapped')
        unwrapped["membership_by_#{resource}_#{key}"] = memberships.group_by do |membership|
          membership[resource][key]
        end.transform_values(&:first)
      end

      # @param task_hash [Hash]
      # @return [void]
      def unwrap_memberships(task_hash)
        unwrap_membership(task_hash, 'section', 'gid')
        unwrap_membership(task_hash, 'section', 'name')
        unwrap_membership(task_hash, 'project', 'gid')
        unwrap_membership(task_hash, 'project', 'name')
      end
    end
  end
end
