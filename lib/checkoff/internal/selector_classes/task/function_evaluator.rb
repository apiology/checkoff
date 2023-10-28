# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Task
      # Base class to evaluate a task selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<(Symbol, Array)>,String]
        # @param tasks [Checkoff::Tasks]
        # @param timelines [Checkoff::Timelines]
        def initialize(selector:,
                       tasks:,
                       timelines:)
          @selector = selector
          @tasks = tasks
          @timelines = timelines
          super()
        end

        private

        # @sg-ignore
        # @param task [Asana::Resources::Task]
        # @param custom_field_gid [String]
        # @return [Hash]
        def pull_custom_field_or_raise(task, custom_field_gid)
          # @type [Array<Hash>]
          custom_fields = task.custom_fields
          if custom_fields.nil?
            raise "Could not find custom_fields under task (was 'custom_fields' included in 'extra_fields'?)"
          end

          # @sg-ignore
          # @type [Hash, nil]
          matched_custom_field = custom_fields.find { |data| data.fetch('gid') == custom_field_gid }
          if matched_custom_field.nil?
            raise "Could not find custom field with gid #{custom_field_gid} " \
                  "in task #{task.gid} with custom fields #{custom_fields}"
          end

          matched_custom_field
        end

        # @return [Array<(Symbol, Array)>]
        attr_reader :selector

        # @sg-ignore
        # @param custom_field [Hash]
        # @return [Array<String>]
        def pull_enum_values(custom_field)
          resource_subtype = custom_field.fetch('resource_subtype')
          case resource_subtype
          when 'enum'
            [custom_field.fetch('enum_value')]
          when 'multi_enum'
            custom_field.fetch('multi_enum_values')
          else
            raise "Teach me how to handle resource_subtype #{resource_subtype}"
          end
        end

        # @param custom_field [Hash]
        # @param enum_value [Object, nil]
        # @return [Array<String>]
        def find_gids(custom_field, enum_value)
          if enum_value.nil?
            []
          else
            raise "Unexpected enabled value on custom field: #{custom_field}" if enum_value.fetch('enabled') == false

            [enum_value.fetch('gid')]
          end
        end

        # @param task [Asana::Resources::Task]
        # @param custom_field_gid [String]
        # @return [Array<String>]
        def pull_custom_field_values_gids(task, custom_field_gid)
          custom_field = pull_custom_field_or_raise(task, custom_field_gid)
          pull_enum_values(custom_field).flat_map do |enum_value|
            find_gids(custom_field, enum_value)
          end
        end

        # @sg-ignore
        # @param task [Asana::Resources::Task]
        # @param custom_field_name [String]
        # @return [Hash, nil]
        def pull_custom_field_by_name(task, custom_field_name)
          custom_fields = task.custom_fields
          if custom_fields.nil?
            raise "custom fields not found on task - did you add 'custom_fields' in your extra_fields argument?"
          end

          # @sg-ignore
          # @type [Hash, nil]
          custom_fields.find { |field| field.fetch('name') == custom_field_name }
        end

        # @param task [Asana::Resources::Task]
        # @param custom_field_name [String]
        # @return [Hash]
        def pull_custom_field_by_name_or_raise(task, custom_field_name)
          custom_field = pull_custom_field_by_name(task, custom_field_name)
          if custom_field.nil?
            raise "Could not find custom field with name #{custom_field_name} " \
                  "in task #{task.gid} with custom fields #{task.custom_fields}"
          end
          custom_field
        end
      end
    end
  end
end
