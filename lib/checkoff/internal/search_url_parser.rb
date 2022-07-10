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
        custom_field_args = convert_custom_field_params(custom_field_params)
        regular_url_args = convert_regular_params(regular_url_params)
        custom_field_args.merge(regular_url_args)
      end

      private

      def convert_regular_params(regular_url_params)
        regular_url_params.to_a.map do |key, values|
          convert_arg(key, values)
        end.to_h
      end

      def convert_custom_field_params(custom_field_params)
        by_custom_field = custom_field_params.group_by do |key, _value|
          gid_from_custom_field_key(key)
        end.transform_values(&:to_h)
        by_custom_field.map do |gid, single_custom_field_params|
          convert_single_custom_field_params(gid, single_custom_field_params)
        end.inject(&:merge).to_h
      end

      def convert_single_custom_field_is_params(remaining_params)
        unless remaining_params.length == 1
          raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
        end

        key, values = remaining_params.to_a[0]
        convert_custom_field_is_arg(key, values)
      end

      def convert_single_custom_field_no_value_params(remaining_params)
        unless remaining_params.length.zero?
          raise "Teach me how to handle these remaining keys for #{variant_key}: #{remaining_params}"
        end

        { 'custom_fields.1234.is_set' => 'false' }
      end

      def convert_single_custom_field_params(gid, single_custom_field_params)
        variant_key = "custom_field_#{gid}.variant"
        variant = single_custom_field_params.fetch(variant_key)
        remaining_params = single_custom_field_params.except(variant_key)
        case variant
        when ['is']
          return convert_single_custom_field_is_params(remaining_params)
        when ['no_value']
          return convert_single_custom_field_no_value_params(remaining_params)
        end

        raise "Teach me how to handle #{variant_key} = #{variant}"
      end

      def convert_custom_field_is_arg(key, values)
        gid = gid_from_custom_field_key(key)

        if key.end_with? '.selected_options'
          raise "Too many values found for #{key}: #{values}" if values.length != 1

          return { "custom_fields.#{gid}.value" => values[0] }
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
