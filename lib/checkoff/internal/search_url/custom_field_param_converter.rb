# typed: false
# frozen_string_literal: true

require_relative 'custom_field_variant'
require_relative 'results_merger'

module Checkoff
  module Internal
    module SearchUrl
      # Convert custom field parameters from an Asana search URL into
      # API search arguments and Checkoff task selectors
      class CustomFieldParamConverter
        # @param custom_field_params [Hash<String, Array<String>>]
        def initialize(custom_field_params:)
          @custom_field_params = custom_field_params
        end

        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)]
        def convert
          # @type args [Hash<String, String>]
          args = {}
          # @type task_selector [Array<[Symbol, Array]>]
          task_selector = []
          by_custom_field.each do |gid, single_custom_field_params|
            # @sg-ignore
            new_args, new_task_selector = convert_single_custom_field_params(gid,
                                                                             single_custom_field_params)

            args = ResultsMerger.merge_args(args, new_args)

            # @sg-ignore
            task_selector = ResultsMerger.merge_task_selectors(task_selector, new_task_selector)
          end
          [args, task_selector]
        end

        private

        # @sg-ignore
        # @return [Hash<String, Hash>]
        def by_custom_field
          custom_field_params.group_by do |key, _value|
            gid_from_custom_field_key(key)
          end.transform_values(&:to_h)
        end

        # @type [Hash<String, Class<CustomFieldVariant>]
        VARIANTS = {
          'is' => CustomFieldVariant::Is,
          'no_value' => CustomFieldVariant::NoValue,
          'any_value' => CustomFieldVariant::AnyValue,
          'is_not' => CustomFieldVariant::IsNot,
          'less_than' => CustomFieldVariant::LessThan,
          'greater_than' => CustomFieldVariant::GreaterThan,
          'equals' => CustomFieldVariant::Equals,
          'doesnt_contain_any' => CustomFieldVariant::DoesntContainAny,
          'contains_any' => CustomFieldVariant::ContainsAny,
          'contains_all' => CustomFieldVariant::ContainsAll,
        }.freeze
        private_constant :VARIANTS

        # @param gid [String]
        # @param single_custom_field_params [Hash<String, Array<String>>]
        # @sg-ignore
        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)]
        def convert_single_custom_field_params(gid, single_custom_field_params)
          variant_key = "custom_field_#{gid}.variant"
          variant = single_custom_field_params.fetch(variant_key)
          remaining_params = single_custom_field_params.reject { |k, _v| k == variant_key }
          raise "Teach me how to handle #{variant_key} = #{variant}" unless variant.length == 1

          # @sg-ignore
          # @type variant_class [Class<CustomFieldVariant>]
          variant_class = VARIANTS[variant[0]]
          # @type [Array(Hash<String, String>, Array<[Symbol, Array]>)]
          # @sg-ignore
          return variant_class.new(gid, remaining_params).convert unless variant_class.nil?

          raise "Teach me how to handle #{variant_key} = #{variant}"
        end

        # @param key [String]
        # @return [String]
        def gid_from_custom_field_key(key)
          key.split('_')[2].split('.')[0]
        end

        # @return [Hash<String, Array<String>>]
        attr_reader :custom_field_params
      end
    end
  end
end
