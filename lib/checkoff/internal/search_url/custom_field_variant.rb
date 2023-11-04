# frozen_string_literal: true

module Checkoff
  module Internal
    module SearchUrl
      # https://developers.asana.com/docs/search-tasks-in-a-workspace
      module CustomFieldVariant
        # base class for handling different custom_field_#{gid}.variant params
        class CustomFieldVariant
          # @param [String] gid
          # @param [Hash] remaining_params
          def initialize(gid, remaining_params)
            @gid = gid
            @remaining_params = remaining_params
          end

          private

          # @return [String]
          attr_reader :gid

          # @return [Hash]
          attr_reader :remaining_params

          # @return [void]
          def ensure_no_remaining_params!
            return if remaining_params.empty?

            raise "Teach me how to handle these remaining keys: #{remaining_params}"
          end

          # @param [String] param_name
          #
          # @return [String]
          def fetch_solo_param(param_name)
            case remaining_params.keys
            when [param_name]
              # @sg-ignore
              # @type [Array<String>]
              param_values = remaining_params.fetch(param_name)
              unless param_values.length == 1
                raise "Teach me how to handle these remaining keys for #{param_name}: #{remaining_params}"
              end

              param_values[0]
            else
              raise "Teach me how to handle #{remaining_params}"
            end
          end
        end

        # custom_field_#{gid}.variant = 'less_than'
        class LessThan < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            max_value = fetch_solo_param("custom_field_#{gid}.max")
            empty_task_selector = []
            [{ "custom_fields.#{gid}.less_than" => max_value }, empty_task_selector]
          end
        end

        # custom_field_#{gid}.variant = 'greater_than'
        class GreaterThan < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            max_value = fetch_solo_param("custom_field_#{gid}.min")
            empty_task_selector = []
            [{ "custom_fields.#{gid}.greater_than" => max_value }, empty_task_selector]
          end
        end

        # custom_field_#{gid}.variant = 'equals'
        class Equals < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            value = fetch_solo_param("custom_field_#{gid}.value")
            empty_task_selector = []
            [{ "custom_fields.#{gid}.value" => value }, empty_task_selector]
          end
        end

        # This is used in the UI for select fields
        #
        # custom_field_#{gid}.variant = 'is_not'
        class IsNot < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            # note: task does not need to contain this custom field
            [{},
             ['not',
              ['custom_field_gid_value_contains_any_gid?',
               gid,
               selected_options]]]
          end
        end

        # This is used in the UI for multi-select fields
        #
        # custom_field_#{gid}.variant = 'doesnt_contain_any'
        class DoesntContainAny < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['not',
              ['custom_field_gid_value_contains_any_gid?',
               gid,
               selected_options]]]
          end
        end

        # This is used in the UI for multi-select fields
        #
        # custom_field_#{gid}.variant = 'contains_any'
        class ContainsAny < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['custom_field_gid_value_contains_any_gid?',
              gid,
              selected_options]]
          end
        end

        # This is used in the UI for multi-select fields
        #
        # custom_field_#{gid}.variant = 'contains_all'
        class ContainsAll < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['custom_field_gid_value_contains_all_gids',
              gid,
              selected_options]]
          end
        end

        # custom_field_#{gid}.variant = 'no_value'
        class NoValue < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            ensure_no_remaining_params!

            api_params = { "custom_fields.#{gid}.is_set" => 'false' }
            # As of 2023-02, the 'is_set' => 'false' seems to not do
            # the intuitive thing on multi-select fields; it either
            # operates as a no-op or operates the same as 'true'; not
            # sure.
            #
            # Let's handle those with a filter afterwards.
            task_selector = [:nil?, [:custom_field_gid_value, gid]]
            [api_params, task_selector]
          end
        end

        # custom_field_#{gid}.variant = 'any_value'
        #
        # Not used for multi-select fields
        class AnyValue < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            ensure_no_remaining_params!

            api_params = { "custom_fields.#{gid}.is_set" => 'true' }
            task_selector = []
            [api_params, task_selector]
          end
        end

        # custom_field_#{gid}.variant = 'is'
        class Is < CustomFieldVariant
          # @return [Array<(Hash, Array)>]
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            empty_task_selector = []
            if selected_options.length == 1
              [{ "custom_fields.#{gid}.value" => selected_options[0] },
               empty_task_selector]
            else
              # As of 2023-01,
              # https://developers.asana.com/reference/searchtasksforworkspace
              # says "Not Supported: searching for multiple exact
              # matches of a custom field".  So I guess we have to
              # search this manually.
              api_params = { "custom_fields.#{gid}.is_set" => 'true' }
              task_selector = [:custom_field_gid_value_contains_any_gid?, gid, selected_options]
              [api_params, task_selector]
            end
          end
        end
      end
    end
  end
end
