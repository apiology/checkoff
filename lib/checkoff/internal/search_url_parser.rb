#!/usr/bin/env ruby

# frozen_string_literal: true

require 'active_support/core_ext/hash/except'

module Checkoff
  module Internal
    # Parse Asana search URLs into parameters suitable to pass into
    # the /workspaces/{workspace_gid}/tasks/search endpoint
    class SearchUrlParser
      def initialize(_deps = {}); end

      def convert_params(url)
        url_params = CGI.parse(URI.parse(url).query)
        custom_field_params, regular_url_params = partition_url_params(url_params)
        custom_field_args, task_selector = convert_custom_field_params(custom_field_params)
        regular_url_args = convert_regular_params(regular_url_params)
        [custom_field_args.merge(regular_url_args), task_selector]
      end

      private

      def convert_regular_params(regular_url_params)
        regular_url_params.to_a.map do |key, values|
          convert_arg(key, values)
        end.to_h
      end

      def merge_args_and_task_selectors(args, new_args, task_selector, new_task_selector)
        args = args.merge(new_args)
        return [args, task_selector] if new_task_selector == []

        raise 'Teach me how to merge task selectors' unless task_selector == []

        task_selector = new_task_selector

        [args, task_selector]
      end

      def convert_custom_field_params(custom_field_params)
        by_custom_field = custom_field_params.group_by do |key, _value|
          gid_from_custom_field_key(key)
        end.transform_values(&:to_h)
        args = {}
        task_selector = []
        by_custom_field.each do |gid, single_custom_field_params|
          new_args, new_task_selector = convert_single_custom_field_params(gid,
                                                                           single_custom_field_params)
          args, task_selector = merge_args_and_task_selectors(args,
                                                              new_args,
                                                              task_selector,
                                                              new_task_selector)
        end
        [args, task_selector]
      end

      def convert_single_custom_field_is_params(remaining_params)
        unless remaining_params.length == 1
          raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
        end

        key, values = remaining_params.to_a[0]
        convert_custom_field_is_arg(key, values)
      end

      def convert_single_custom_field_no_value_params(gid, remaining_params)
        unless remaining_params.length.zero?
          raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
        end

        empty_task_selector = []
        [{ "custom_fields.#{gid}.is_set" => 'false' }, empty_task_selector]
      end

      def convert_single_custom_field_is_not_params_selected_options(gid, remaining_params)
        selected_options = remaining_params.fetch("custom_field_#{gid}.selected_options")
        raise "Teach me how to handle #{remaining_params}" unless selected_options.length == 1

        [{ "custom_fields.#{gid}.is_set" => 'true' },
         ['not',
          ['custom_field_gid_value_contains_any_gid',
           gid,
           selected_options.fetch(0).split('~')]]]
      end

      def convert_single_custom_field_is_not_params(gid, remaining_params)
        case remaining_params.keys
        when ["custom_field_#{gid}.selected_options"]
          convert_single_custom_field_is_not_params_selected_options(gid, remaining_params)
        else
          raise "Teach me how to handle #{remaining_params}"
        end
      end

      def convert_single_custom_field_less_than_params_max_param(max_param, gid, remaining_params)
        max_values = remaining_params.fetch(max_param)
        unless max_values.length == 1
          raise "Teach me how to handle these remaining keys for #{max_param}: #{remaining_params}"
        end

        max_value = max_values[0]
        empty_task_selector = []
        [{ "custom_fields.#{gid}.less_than" => max_value }, empty_task_selector]
      end

      def convert_single_custom_field_less_than_params(gid, remaining_params)
        max_param = "custom_field_#{gid}.max"
        case remaining_params.keys
        when [max_param]
          convert_single_custom_field_less_than_params_max_param(max_param, gid, remaining_params)
        else
          raise "Teach me how to handle #{remaining_params}"
        end
      end

      def convert_single_custom_field_params(gid, single_custom_field_params)
        variant_key = "custom_field_#{gid}.variant"
        variant = single_custom_field_params.fetch(variant_key)
        remaining_params = single_custom_field_params.except(variant_key)
        case variant
        when ['is']
          return convert_single_custom_field_is_params(remaining_params)
        when ['no_value']
          return convert_single_custom_field_no_value_params(gid, remaining_params)
        when ['is_not']
          return convert_single_custom_field_is_not_params(gid, remaining_params)
        when ['less_than']
          return convert_single_custom_field_less_than_params(gid, remaining_params)
        end

        raise "Teach me how to handle #{variant_key} = #{variant}"
      end

      def convert_custom_field_is_arg(key, values)
        gid = gid_from_custom_field_key(key)
        empty_task_selector = []

        if key.end_with? '.selected_options'
          raise "Too many values found for #{key}: #{values}" if values.length != 1

          return [{ "custom_fields.#{gid}.value" => values[0] },
                  empty_task_selector]
        end

        raise "Teach me how to handle #{key} = #{values}"
      end

      def partition_url_params(url_params)
        url_params.to_a.partition do |key, _values|
          key.start_with? 'custom_field_'
        end.map(&:to_h)
      end

      PARAM_MAP = {
        'any_projects.ids' => 'projects.any',
      }.freeze

      def gid_from_custom_field_key(key)
        key.split('_')[2].split('.')[0]
      end

      def convert_arg(key, values)
        return convert_custom_field_arg(key, values) if key.start_with? 'custom_field_'

        [PARAM_MAP.fetch(key), values.join(',')]
      end
    end
  end
end
