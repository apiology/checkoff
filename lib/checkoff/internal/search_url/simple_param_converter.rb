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
          # @param key [String] the name of the search url param
          # @param values [Array<String>] the values of the search url param
          def initialize(key:, values:)
            @key = key
            @values = values
          end

          private

          # @sg-ignore
          # @return [String] the single value of the search url param
          def single_value
            @single_value ||= begin
              raise "Teach me how to handle #{key} = #{values}" if values.length != 1

              # @type [String]
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
              # @sg-ignore
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
            case single_value
            when 'incomplete'
              ['completed', false]
            when 'complete'
              ['completed', true]
            else
              raise "Teach me how to handle #{key} = #{values}"
            end
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

        # Handle 'sort' search url param
        class Sort < SimpleParam
          def convert
            # https://developers.asana.com/reference/searchtasksforworkspace
            conversion = {
              'last_modified' => 'modified_at',
              'due_date' => 'due_date',
              'creation_time' => 'created_at',
              'completion_time' => 'completed_at',
              'likes' => 'likes',
            }
            ['sort_by', conversion.fetch(single_value)]
          end
        end
      end

      # Convert simple parameters - ones where the param name itself
      # doesn't encode any parameters'
      class SimpleParamConverter
        # @param simple_url_params [Hash<String, Array<String>>] the simple params
        def initialize(simple_url_params:)
          @simple_url_params = simple_url_params
        end

        # @return [Hash<String, String>] the converted params
        def convert
          simple_url_params.to_a.flat_map do |key, values|
            convert_arg(key, values).each_slice(2).to_a
          end.to_h
        end

        private

        # @type [Hash<String, Class<SimpleParam::SimpleParam>>] the mapping from param name to class
        ARGS = {
          'any_projects.ids' => SimpleParam::AnyProjectsIds,
          'not_projects.ids' => SimpleParam::NotProjectsIds,
          'completion' => SimpleParam::Completion,
          'not_tags.ids' => SimpleParam::NotTagsIds,
          'any_tags.ids' => SimpleParam::AnyTagsIds,
          'subtask' => SimpleParam::Subtask,
          'sort' => SimpleParam::Sort,
        }.freeze

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        # @sg-ignore
        # @param key [String] the name of the search url param
        # @param values [Array<String>] the values of the search url param
        # @return [Hash<String, String>] the converted params
        def convert_arg(key, values)
          # @type [Class<SimpleParam::SimpleParam>]
          clazz = ARGS.fetch(key)
          # @type [SimpleParam::SimpleParam]
          obj = clazz.new(key: key, values: values)
          # @sg-ignore
          obj.convert
        end

        attr_reader :simple_url_params
      end
    end
  end
end
