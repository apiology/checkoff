#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'custom_field_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      # Parse Asana search URLs into parameters suitable to pass into
      # the /workspaces/{workspace_gid}/tasks/search endpoint
      class Parser
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

        def convert_custom_field_params(custom_field_params)
          CustomFieldParamConverter.new(custom_field_params: custom_field_params).convert
        end

        def partition_url_params(url_params)
          url_params.to_a.partition do |key, _values|
            key.start_with? 'custom_field_'
          end.map(&:to_h)
        end

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        def convert_arg(key, values)
          case key
          when 'any_projects.ids'
            ['projects.any', values.join(',')]
          when 'completion'
            raise "Teach me how to handle #{key} = #{values}" if values.length != 1

            value = values.fetch(0)
            raise "Teach me how to handle #{key} = #{values}" if value != 'incomplete'

            ['completed', false]
          when 'not_tags.ids'
            raise "Teach me how to handle #{key} = #{values}" if values.length != 1

            value = values.fetch(0)
            tag_ids = value.split('~')
            ['tags.not', tag_ids.join(',')]
          else
            raise "Teach me how to handle #{key} = #{values}"
          end
        end
      end
    end
  end
end
