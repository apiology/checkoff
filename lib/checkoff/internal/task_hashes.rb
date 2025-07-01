# typed: true
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
        unwrap_all_memberships(task_hash)
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
        Asana::Resources::Task.new(clean_task_data, client:)
      end

      private

      # @param task_hash [Hash]
      # @return [void]
      def unwrap_custom_fields(task_hash)
        # @sg-ignore
        # @type [Array<Hash>,nil]
        custom_fields = task_hash.fetch('custom_fields', nil)

        return if custom_fields.nil?

        unwrapped_custom_fields = custom_fields.group_by do |cf|
          cf['name']
        end.transform_values(&:first)
        task_hash['unwrapped']['custom_fields'] = unwrapped_custom_fields
      end

      # @param [Hash{String => String, Hash, Array}] task_hash
      # @param [Array<Hash>] memberships
      #
      # @return [void]
      def add_user_task_list(task_hash, memberships)
        return unless task_hash.key? 'assignee_section'

        assignee_section = task_hash.fetch('assignee_section')
        # @type [Hash{String => String}]
        assignee = T.cast(task_hash.fetch('assignee'), T::Hash[String, String])
        memberships << {
          'section' => assignee_section.dup,
          'project' => {
            'gid' => assignee.fetch('gid'),
            'name' => :my_tasks,
          },
        }
      end

      # @param task_hash [Hash]
      # @param resource [String]
      # @param memberships [Array<Hash>]
      # @param key [String]
      #
      # @return [void]
      def unwrap_memberships(task_hash, memberships, resource, key)
        # @sg-ignore
        # @type [Hash]
        unwrapped = task_hash.fetch('unwrapped')
        unwrapped["membership_by_#{resource}_#{key}"] = memberships.group_by do |membership|
          membership[resource][key]
        end.transform_values(&:first)
      end

      # @param task_hash [Hash]
      # @return [void]
      def unwrap_all_memberships(task_hash)
        # @sg-ignore
        # @type [Array<Hash>]
        memberships = task_hash.fetch('memberships', []).dup
        add_user_task_list(task_hash, memberships)
        unwrap_memberships(task_hash, memberships, 'section', 'gid')
        unwrap_memberships(task_hash, memberships, 'section', 'name')
        unwrap_memberships(task_hash, memberships, 'project', 'gid')
        unwrap_memberships(task_hash, memberships, 'project', 'name')
      end
    end
  end
end
