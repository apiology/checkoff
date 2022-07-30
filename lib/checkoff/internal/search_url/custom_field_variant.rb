# frozen_string_literal: true

module Checkoff
  module Internal
    module SearchUrl
      module CustomFieldVariant
        # base class for handling different custom_field_#{gid}.variant params
        class CustomFieldVariant
          def initialize(gid, remaining_params)
            @gid = gid
            @remaining_params = remaining_params
          end

          private

          attr_reader :gid, :remaining_params
        end

        # custom_field_#{gid}.variant = 'less_than'
        class LessThan < CustomFieldVariant
          def convert
            max_param = "custom_field_#{gid}.max"
            case remaining_params.keys
            when [max_param]
              convert_single_custom_field_less_than_params_max_param(max_param)
            else
              raise "Teach me how to handle #{remaining_params}"
            end
          end

          private

          def convert_single_custom_field_less_than_params_max_param(max_param)
            max_values = remaining_params.fetch(max_param)
            unless max_values.length == 1
              raise "Teach me how to handle these remaining keys for #{max_param}: #{remaining_params}"
            end

            max_value = max_values[0]
            empty_task_selector = []
            [{ "custom_fields.#{gid}.less_than" => max_value }, empty_task_selector]
          end
        end

        # custom_field_#{gid}.variant = 'is_not'
        class IsNot < CustomFieldVariant
          def convert
            case remaining_params.keys
            when ["custom_field_#{gid}.selected_options"]
              convert_single_custom_field_is_not_params_selected_options
            else
              raise "Teach me how to handle #{remaining_params}"
            end
          end

          private

          def convert_single_custom_field_is_not_params_selected_options
            selected_options = remaining_params.fetch("custom_field_#{gid}.selected_options")
            raise "Teach me how to handle #{remaining_params}" unless selected_options.length == 1

            [{ "custom_fields.#{gid}.is_set" => 'true' },
             ['not',
              ['custom_field_gid_value_contains_any_gid',
               gid,
               selected_options.fetch(0).split('~')]]]
          end
        end

        # custom_field_#{gid}.variant = 'no_value'
        class NoValue < CustomFieldVariant
          def convert
            unless remaining_params.length.zero?
              raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
            end

            empty_task_selector = []
            [{ "custom_fields.#{gid}.is_set" => 'false' }, empty_task_selector]
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
