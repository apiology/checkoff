# frozen_string_literal: true

require_relative 'custom_field_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      module SimpleParam
        # base class for handling different types of search url params
        class SimpleParam
          def initialize(values:)
            @values = values
          end

          private

          attr_reader :values
        end

        # Handle 'any_projects.ids' search url param
        class AnyProjectsIds < SimpleParam
          def convert
            ['projects.any', values.join(',')]
          end
        end

        # Handle 'completion' search url param
        class Completion < SimpleParam
          def convert
            raise "Teach me how to handle #{key} = #{values}" if values.length != 1

            value = values.fetch(0)
            raise "Teach me how to handle #{key} = #{values}" if value != 'incomplete'

            ['completed', false]
          end
        end

        # Handle 'not_tags.ids' search url param
        class NotTagsIds < SimpleParam
          def convert
            raise "Teach me how to handle #{key} = #{values}" if values.length != 1

            value = values.fetch(0)
            tag_ids = value.split('~')
            ['tags.not', tag_ids.join(',')]
          end
        end
      end

      # Convert simple parameters - ones where the param name itself
      # doesn't encode any parameters'
      class SimpleParamConverter
        def initialize(simple_url_params:)
          @simple_url_params = simple_url_params
        end

        def convert
          simple_url_params.to_a.map do |key, values|
            convert_arg(key, values)
          end.to_h
        end

        private

        ARGS = {
          'any_projects.ids' => SimpleParam::AnyProjectsIds,
          'completion' => SimpleParam::Completion,
          'not_tags.ids' => SimpleParam::NotTagsIds,
        }.freeze

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        def convert_arg(key, values)
          clazz = ARGS.fetch(key)
          clazz.new(values: values).convert
        end

        attr_reader :simple_url_params
      end
    end
  end
end
