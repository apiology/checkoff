# frozen_string_literal: true

require_relative 'custom_field_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      # See
      # https://developers.asana.com/docs/search-tasks-in-a-workspace
      # for the return value of 'convert' here:
      module SimpleParam
        # base class for handling different types of search url params
        class SimpleParam
          def initialize(key:, values:)
            @key = key
            @values = values
          end

          private

          def single_value
            @single_value ||= begin
              raise "Teach me how to handle #{key} = #{values}" if values.length != 1

              values.fetch(0)
            end
          end

          attr_reader :key, :values

          # Inputs:
          #   123_column_456 means "abc" project, "def" section
          #   123 means "abc" project
          #   123~456 means "abc" and "def" projects
          def parse_projects_and_sections(projects, sections)
            single_value.split('~').each do |project_section_pair|
              project, section = project_section_pair.split('_column_')
              if section.nil?
                projects << project
              else
                sections << section
              end
            end
          end

          def convert_from_projects_and_sections(verb)
            projects = []
            sections = []
            parse_projects_and_sections(projects, sections)
            out = {}
            out["projects.#{verb}"] = projects.join(',') unless projects.empty?
            out["sections.#{verb}"] = sections.join(',') unless sections.empty?
            out.to_a.flatten
          end
        end

        # Handle 'any_projects.ids' search url param
        class AnyProjectsIds < SimpleParam
          def convert
            convert_from_projects_and_sections('any')
          end
        end

        # Handle 'not_projects.ids' search url param
        class NotProjectsIds < SimpleParam
          def convert
            convert_from_projects_and_sections('not')
          end
        end

        # Handle 'completion' search url param
        class Completion < SimpleParam
          def convert
            raise "Teach me how to handle #{key} = #{values}" if single_value != 'incomplete'

            ['completed', false]
          end
        end

        # Handle 'not_tags.ids' search url param
        class NotTagsIds < SimpleParam
          def convert
            tag_ids = single_value.split('~')
            ['tags.not', tag_ids.join(',')]
          end
        end

        # handle 'subtask' search url param
        class Subtask < SimpleParam
          def convert
            return ['is_subtask', false] if single_value == 'is_not_subtask'

            raise "Teach me how to handle #{key} = #{values}"
          end
        end

        # Handle 'any_tags.ids' search url param
        class AnyTagsIds < SimpleParam
          def convert
            tag_ids = single_value.split('~')
            ['tags.any', tag_ids.join(',')]
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
          simple_url_params.to_a.flat_map do |key, values|
            convert_arg(key, values).each_slice(2).to_a
          end.to_h
        end

        private

        ARGS = {
          'any_projects.ids' => SimpleParam::AnyProjectsIds,
          'not_projects.ids' => SimpleParam::NotProjectsIds,
          'completion' => SimpleParam::Completion,
          'not_tags.ids' => SimpleParam::NotTagsIds,
          'any_tags.ids' => SimpleParam::AnyTagsIds,
          'subtask' => SimpleParam::Subtask,
        }.freeze

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        def convert_arg(key, values)
          clazz = ARGS.fetch(key)
          clazz.new(key: key, values: values).convert
        end

        attr_reader :simple_url_params
      end
    end
  end
end
