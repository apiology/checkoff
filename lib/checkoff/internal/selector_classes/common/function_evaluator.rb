# frozen_string_literal: true

require_relative '../function_evaluator'

module Checkoff
  module SelectorClasses
    module Common
      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < ::Checkoff::SelectorClasses::FunctionEvaluator
        # @param selector [Array<(Symbol, Array)>,String]
        def initialize(selector:, **_kwargs)
          @selector = selector
          super()
        end

        private

        # @param project [Asana::Resources::Project]
        # @param field_name [Symbol]
        #
        # @sg-ignore
        # @return [Date, nil]
        def pull_date_field_by_name(project, field_name)
          if field_name == :modified
            return Time.parse(project.modified_at).to_date unless project.modified_at.nil?

            return nil
          end

          if field_name == :due
            return Time.parse(project.due_at).to_date unless project.due_at.nil?

            return Date.parse(project.due_on) unless project.due_on.nil?

            return nil
          end

          raise "Teach me how to handle field #{field_name}"
        end

        # @param project [Asana::Resources::Project]
        # @param field_name [Symbol]
        #
        # @sg-ignore
        # @return [Date, Time, nil]
        def pull_date_or_time_field_by_name(project, field_name)
          if field_name == :due
            return Time.parse(project.due_at) unless project.due_at.nil?

            return Date.parse(project.due_on) unless project.due_on.nil?

            return nil
          end

          if field_name == :start
            return Time.parse(project.start_at) unless project.start_at.nil?

            return Date.parse(project.start_on) unless project.start_on.nil?

            return nil
          end

          raise "Teach me how to handle field #{field_name}"
        end

        # @sg-ignore
        # @param project [Asana::Resources::Project]
        # @param custom_field_gid [String]
        # @return [Hash]
        def pull_custom_field_or_raise(project, custom_field_gid)
          # @type [Array<Hash>]
          custom_fields = project.custom_fields
          if custom_fields.nil?
            raise "Could not find custom_fields under project (was 'custom_fields' included in 'extra_fields'?)"
          end

          # @sg-ignore
          # @type [Hash, nil]
          matched_custom_field = custom_fields.find { |data| data.fetch('gid') == custom_field_gid }
          if matched_custom_field.nil?
            raise "Could not find custom field with gid #{custom_field_gid} " \
                  "in project #{project.gid} with custom fields #{custom_fields}"
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

        # @param project [Asana::Resources::Project]
        # @param custom_field_gid [String]
        # @return [Array<String>]
        def pull_custom_field_values_gids(project, custom_field_gid)
          custom_field = pull_custom_field_or_raise(project, custom_field_gid)
          pull_enum_values(custom_field).flat_map do |enum_value|
            find_gids(custom_field, enum_value)
          end
        end

        # @sg-ignore
        # @param project [Asana::Resources::Project]
        # @param custom_field_name [String]
        # @return [Hash, nil]
        def pull_custom_field_by_name(project, custom_field_name)
          custom_fields = project.custom_fields
          if custom_fields.nil?
            raise "custom fields not found on project - did you add 'custom_fields' in your extra_fields argument?"
          end

          # @sg-ignore
          # @type [Hash, nil]
          custom_fields.find { |field| field.fetch('name') == custom_field_name }
        end

        # @param project [Asana::Resources::Project]
        # @param custom_field_name [String]
        # @return [Hash]
        def pull_custom_field_by_name_or_raise(project, custom_field_name)
          custom_field = pull_custom_field_by_name(project, custom_field_name)
          if custom_field.nil?
            raise "Could not find custom field with name #{custom_field_name} " \
                  "in project #{project.gid} with custom fields #{project.custom_fields}"
          end
          custom_field
        end
      end
    end
  end
end
