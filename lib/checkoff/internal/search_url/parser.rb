#!/usr/bin/env ruby

# frozen_string_literal: true

require 'cgi'
require 'uri'
require_relative 'simple_param_converter'
require_relative 'custom_field_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      # Parse Asana search URLs into parameters suitable to pass into
      # the /workspaces/{workspace_gid}/tasks/search endpoint
      class Parser
        def initialize(_deps = {})
          # allow dependencies to be passed in by tests
        end

        def convert_params(url)
          url_params = CGI.parse(URI.parse(url).query)
          # @sg-ignore
          custom_field_params, simple_url_params = partition_url_params(url_params)
          # @sg-ignore
          custom_field_args, task_selector = convert_custom_field_params(custom_field_params)
          simple_url_args = convert_simple_params(simple_url_params)
          [custom_field_args.merge(simple_url_args), task_selector]
        end

        private

        def convert_simple_params(simple_url_params)
          SimpleParamConverter.new(simple_url_params: simple_url_params).convert
        end

        def convert_custom_field_params(custom_field_params)
          CustomFieldParamConverter.new(custom_field_params: custom_field_params).convert
        end

        # @param url_params [Hash<String, String>]
        # @return [Array(Hash<String, String>, Hash<String, String>)]
        def partition_url_params(url_params)
          url_params.to_a.partition do |key, _values|
            key.start_with? 'custom_field_'
          end.map(&:to_h)
        end
      end
    end
  end
end
