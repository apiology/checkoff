#!/usr/bin/env ruby

# frozen_string_literal: true

module Checkoff
  module Internal
    class SearchUrlParser
      def initialize(_deps = {}); end

      def convert_args(url)
        url_params = CGI.parse(URI.parse(url).query)
        url_params.to_a.map { |key, values| convert_arg(key, values) }.to_h
      end

      private

      PARAM_MAP = {
        'any_projects.ids' => 'projects.any',
      }.freeze

      def gid_from_custom_field_key(key)
        key.split('_')[2].split('.')[0]
      end

      def convert_custom_field_variant_arg(gid, key, values)
        case values
        when ['no_value']
          # appears when you search for a text or numeric field 'With no value'
          return ["custom_fields.#{gid}.is_set", 'false']
        when ['is']
          return ["custom_fields.#{gid}.is_set", 'true']
#        when ['is_not']
#          # appears when you search for an enum field 'With no value'
        end

        raise "Teach me how to handle #{key} = #{values}"
      end

      def convert_custom_field_arg(key, values)
        gid = gid_from_custom_field_key(key)
        return convert_custom_field_variant_arg(gid, key, values) if key.end_with? '.variant'

        if key.end_with? '.selected_options'
          raise "Too many values found for #{key}: #{values}" if values.length != 1

          return ["custom_fields.#{gid}.value", values[0]]
        end

        raise "Teach me how to handle #{key} = #{values}"
      end

      def convert_arg(key, values)
        return convert_custom_field_arg(key, values) if key.start_with? 'custom_field_'

        [PARAM_MAP.fetch(key), values.join(',')]
      end
    end
  end
end
