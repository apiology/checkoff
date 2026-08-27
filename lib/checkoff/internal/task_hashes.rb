# typed: true
# frozen_string_literal: true

module Checkoff
  module Internal
    # Builds on the standard API representation of an Asana task with some
    # convenience keys.
    class TaskHashes
      # The two custom_fields entries below hold the same records: the top-level
      # array is what Asana returns, and unwrapped re-keys those records by name.
      #
      # @param task [Asana::Resources::Task]
      #
      # @return [Hash{"gid" => String} &
      #   Hash{"name" => String} &
      #   Hash{"task" => String} &
      #   Hash{"memberships" => Array<Hash{String => Object}>} &
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
      #   }} &
      #   Hash{"membership_by_section_gid" => Hash{String => Hash{String => Object}}} &
      #   Hash{"membership_by_section_name" => Hash{String => Hash{String => Object}}} &
      #   Hash{"membership_by_project_gid" => Hash{String => Hash{String => Object}}} &
      #   Hash{"membership_by_project_name" => Hash{String => Hash{String => Object}}}}]
      def task_to_h(task)
        # @type [Hash{String => Object}]
        task_hash = task.to_h
        task_hash['unwrapped'] = {}
        unwrap_custom_fields(task_hash)
        unwrap_all_memberships(task_hash)
        task_hash['task'] = task.name
        task_hash
      end

      # @param task_data [Hash{String => Object}]
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
        # @type [Array<Hash{String => Object}>,nil]
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
        assignee = assignee_hash(task_hash)
        memberships << {
          'section' => assignee_section.dup,
          'project' => {
            'gid' => assignee.fetch('gid'),
            'name' => :my_tasks,
          },
        }
      end

      # @param task_hash [Hash{String => String, Hash, Array}]
      # @return [Hash{String => Object}]
      def assignee_hash(task_hash)
        assignee = task_hash.fetch('assignee')
        raise "Expected assignee to be a Hash, got #{assignee.class}" unless assignee.is_a?(Hash)

        assignee
      end

      # @param task_hash [Hash{String => Object}]
      # @param resource [String]
      # @param memberships [Array<Hash>]
      # @param key [String]
      #
      # @return [void]
      def unwrap_memberships(task_hash, memberships, resource, key)
        # @type [Hash{String => Object}]
        unwrapped = task_hash.fetch('unwrapped')
        unwrapped["membership_by_#{resource}_#{key}"] = memberships.group_by do |membership|
          membership[resource][key]
        end.transform_values(&:first)
      end

      # @param task_hash [Hash{String => Object}]
      # @return [void]
      def unwrap_all_memberships(task_hash)
        # @type [Array<Hash{String => Object}>]
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
