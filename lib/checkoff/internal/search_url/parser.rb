#!/usr/bin/env ruby

# frozen_string_literal: true

require 'cgi'
require 'uri'
require_relative 'simple_param_converter'
require_relative 'custom_field_param_converter'
require_relative 'results_merger'
require_relative 'date_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      # Parse Asana search URLs into parameters suitable to pass into
      # the /workspaces/{workspace_gid}/tasks/search endpoint
      class Parser
        # @param _deps [Hash]
        def initialize(_deps = {})
          # allow dependencies to be passed in by tests
        end

        # @param url [String]
        # @return [Array(Hash<String, String>, Hash<String, String>)]
        def convert_params(url)
          url_params = CGI.parse(URI.parse(url).query)
          # @type custom_field_params [Hash<String, Array<String>>]
          # @type date_url_params [Hash<String, Array<String>>]
          # @type simple_url_params [Hash<String, Array<String>>]
          # @sg-ignore
          custom_field_params, date_url_params, simple_url_params = partition_url_params(url_params)
          # @type custom_field_args [Hash<String, String>]
          # @type custom_field_task_selector [Hash<String, String>]
          # @sg-ignore
          custom_field_args, custom_field_task_selector = convert_custom_field_params(custom_field_params)
          # @type date_args [Hash<String, String>]
          # @type date_task_selector [Hash<String, String>]
          # @sg-ignore
          date_url_args, date_task_selector = convert_date_params(date_url_params)
          simple_url_args = convert_simple_params(simple_url_params)
          # raise 'merge these things'
          [ResultsMerger.merge_args(custom_field_args, date_url_args, simple_url_args),
           ResultsMerger.merge_task_selectors(date_task_selector, custom_field_task_selector)]
        end

        private

        # @param date_url_params [Hash<String, Array<String>>]
        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)]
        def convert_date_params(date_url_params)
          DateParamConverter.new(date_url_params: date_url_params).convert
        end

        # @param simple_url_params [Hash<String, Array<String>>]
        # @return [Hash<String, String>]
        def convert_simple_params(simple_url_params)
          SimpleParamConverter.new(simple_url_params: simple_url_params).convert
        end

        # @param custom_field_params [Hash<String, Array<String>>]
        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)]
        def convert_custom_field_params(custom_field_params)
          CustomFieldParamConverter.new(custom_field_params: custom_field_params).convert
        end

        # @param url_params [Hash<String, String>]
        # @return [Array(Hash<String, String>, Hash<String, String>, Hash<String, String>)]
        def partition_url_params(url_params)
          groups = url_params.to_a.group_by do |key, _values|
            if key.start_with? 'custom_field_'
              :custom_field
            elsif key.include? '_date'
              :date
            else
              :simple
            end
          end.transform_values(&:to_h)
          # @sg-ignore
          [groups.fetch(:custom_field, {}), groups.fetch(:date, {}), groups.fetch(:simple, {})]
        end
      end
    end
  end
end
