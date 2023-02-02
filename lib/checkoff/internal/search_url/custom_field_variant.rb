# frozen_string_literal: true

module Checkoff
  module Internal
    module SearchUrl
      # https://developers.asana.com/docs/search-tasks-in-a-workspace
      module CustomFieldVariant
        # base class for handling different custom_field_#{gid}.variant params
        class CustomFieldVariant
          def initialize(gid, remaining_params)
            @gid = gid
            @remaining_params = remaining_params
          end

          private

          attr_reader :gid, :remaining_params

          def fetch_solo_param(param_name)
            case remaining_params.keys
            when [param_name]
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
          def convert
            max_value = fetch_solo_param("custom_field_#{gid}.max")
            empty_task_selector = []
            [{ "custom_fields.#{gid}.less_than" => max_value }, empty_task_selector]
          end
        end

        # custom_field_#{gid}.variant = 'greater_than'
        class GreaterThan < CustomFieldVariant
          def convert
            max_value = fetch_solo_param("custom_field_#{gid}.min")
            empty_task_selector = []
            [{ "custom_fields.#{gid}.greater_than" => max_value }, empty_task_selector]
          end
        end

        # This is used in the UI for select fields
        #
        # custom_field_#{gid}.variant = 'is_not'
        class IsNot < CustomFieldVariant
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['not',
              ['custom_field_gid_value_contains_any_gid',
               gid,
               selected_options]]]
          end
        end

        # This is used in the UI for multi-select fields
        #
        # custom_field_#{gid}.variant = 'doesnt_contain_any'
        class DoesntContainAny < CustomFieldVariant
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['not',
              ['custom_field_gid_value_contains_any_gid',
               gid,
               selected_options]]]
          end
        end

        # This is used in the UI for multi-select fields
        #
        # custom_field_#{gid}.variant = 'contains_any'
        class ContainsAny < CustomFieldVariant
          def convert
            selected_options = fetch_solo_param("custom_field_#{gid}.selected_options").split('~')

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['custom_field_gid_value_contains_any_gid',
              gid,
              selected_options]]
          end
        end

        # custom_field_#{gid}.variant = 'no_value'
        class NoValue < CustomFieldVariant
          def convert
            unless remaining_params.length.zero?
              raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
            end

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

        # custom_field_#{gid}.variant = 'is'
        class Is < CustomFieldVariant
          def convert
            unless remaining_params.length == 1
              raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
            end

            key, values = remaining_params.to_a[0]
            convert_custom_field_is_arg(key, values)
          end

          private

          def convert_custom_field_is_arg(key, values)
            empty_task_selector = []

            if key.end_with? '.selected_options'
              raise "Too many values found for #{key}: #{values}" if values.length != 1

              return [{ "custom_fields.#{gid}.value" => values[0] },
                      empty_task_selector]
            end

            raise "Teach me how to handle #{key} = #{values}"
          end
        end
      end
    end
  end
end
