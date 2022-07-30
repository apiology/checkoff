#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'custom_field_variant'

module Checkoff
  module Internal
    module SearchUrl
      # Convert custom field parameters from an Asana search URL into
      # API search arguments and Checkoff task selectors
      class CustomFieldParamConverter
        def initialize(custom_field_params:)
          @custom_field_params = custom_field_params
        end

        def convert
          args = {}
          task_selector = []
          by_custom_field.each do |gid, single_custom_field_params|
            new_args, new_task_selector = convert_single_custom_field_params(gid,
                                                                             single_custom_field_params)
            args, task_selector = merge_args_and_task_selectors(args, new_args,
                                                                task_selector, new_task_selector)
          end
          [args, task_selector]
        end

        private

        def by_custom_field
          custom_field_params.group_by do |key, _value|
            gid_from_custom_field_key(key)
          end.transform_values(&:to_h)
        end

        def merge_args_and_task_selectors(args, new_args, task_selector, new_task_selector)
          args = args.merge(new_args)
          return [args, task_selector] if new_task_selector == []

          raise 'Teach me how to merge task selectors' unless task_selector == []

          task_selector = new_task_selector

          [args, task_selector]
        end

        VARIANTS = {
          'is' => CustomFieldVariant::Is,
          'no_value' => CustomFieldVariant::NoValue,
          'is_not' => CustomFieldVariant::IsNot,
          'less_than' => CustomFieldVariant::LessThan,
        }.freeze

        def convert_single_custom_field_params(gid, single_custom_field_params)
          variant_key = "custom_field_#{gid}.variant"
          variant = single_custom_field_params.fetch(variant_key)
          remaining_params = single_custom_field_params.reject { |k, _v| k == variant_key }
          raise "Teach me how to handle #{variant_key} = #{variant}" unless variant.length == 1

          variant_class = VARIANTS[variant[0]]
          return variant_class.new(gid, remaining_params).convert unless variant_class.nil?

          raise "Teach me how to handle #{variant_key} = #{variant}"
        end

        def gid_from_custom_field_key(key)
          key.split('_')[2].split('.')[0]
        end

        attr_reader :custom_field_params
      end
    end
  end
end
