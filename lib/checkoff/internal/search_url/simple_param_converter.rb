# typed: false
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

          # @return [String]
          attr_reader :key

          # @return [Array<String>]
          attr_reader :values

          # Inputs:
          #   123_column_456 means "abc" project, "def" section
          #   123 means "abc" project
          #   123~456 means "abc" and "def" projects
          #
          # @param projects [Array<String>]
          # @param sections [Array<String>]
          # @return [void]
          def parse_projects_and_sections(projects, sections)
            single_value.split('~').each do |project_section_pair|
              # @sg-ignore
              project, section = project_section_pair.split('_column_')
              raise "Invalid query string: #{project_section_pair}" if project.nil?

              if section.nil?
                projects << project
              else
                sections << section
              end
            end
          end

          # @param verb [String]
          # @return [Array<String>]
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

        # Handle 'portfolios.ids' search url param
        class PortfoliosIds < SimpleParam
          # @return [Array<String>]
          def convert
            { 'portfolios.any' => single_value.split('~').join(',') }.to_a.flatten
          end
        end

        # Handle 'any_projects.ids' search url param
        class AnyProjectsIds < SimpleParam
          # @return [Array<String>]
          def convert
            convert_from_projects_and_sections('any')
          end
        end

        # Handle 'not_projects.ids' search url param
        class NotProjectsIds < SimpleParam
          # @return [Array<String>]
          def convert
            convert_from_projects_and_sections('not')
          end
        end

        # Handle 'completion' search url param
        class Completion < SimpleParam
          # @return [Array<String,Boolean>]
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
          # @return [Array<String>]
          def convert
            tag_ids = single_value.split('~')
            ['tags.not', tag_ids.join(',')]
          end
        end

        # handle 'subtask' search url param
        class Subtask < SimpleParam
          # @return [Array<String, Boolean>]
          def convert
            case single_value
            when 'is_not_subtask'
              ['is_subtask', false]
            when 'is_subtask'
              ['is_subtask', true]
            else
              raise "Teach me how to handle #{key} = #{values}"
            end
          end
        end

        # Handle 'any_tags.ids' search url param
        class AnyTagsIds < SimpleParam
          # @return [Array<String>]
          def convert
            tag_ids = single_value.split('~')
            ['tags.any', tag_ids.join(',')]
          end
        end

        # Handle 'sort' search url param
        class Sort < SimpleParam
          # @return [Array<String>]
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

        # Handle 'milestone' search url param
        class Milestone < SimpleParam
          # @return [Array<String>]
          def convert
            return %w[resource_subtype milestone] if single_value == 'is_milestone'

            return %w[resource_subtype default_task] if single_value == 'is_not_milestone'

            raise "Teach me how to handle #{key} = #{values}"
          end
        end

        # Handle 'searched_type' search url param
        class SearchedType < SimpleParam
          # @return [Array<String>]
          def convert
            return [] if single_value == 'task'

            raise "Teach me how to handle #{key} = #{values}"
          end
        end
      end

      # Convert simple parameters - ones where the param name itself
      # doesn't encode any parameters'
      class SimpleParamConverter
        # @param simple_url_params [Hash{String => Array<String>}] the simple params
        def initialize(simple_url_params:)
          @simple_url_params = simple_url_params
        end

        # @return [Hash{String => String}] the converted params
        def convert
          # @type [Array<Array(String, String)>]
          arr_of_tuples = simple_url_params.to_a.flat_map do |key, values|
            # @type
            entry = convert_arg(key, values).each_slice(2).to_a
            entry
          end
          # @type [Hash{String => String}]
          out = T.cast(arr_of_tuples.to_h, T::Hash[String, String])
          unless out.include? 'sort_by'
            # keep results consistent between calls; API using default
            # sort_by does not seem to be.
            out['sort_by'] = 'created_at'
          end
          out
        end

        private

        # @type [Hash{String => Class<SimpleParam::SimpleParam>}] the mapping from param name to class
        ARGS = {
          'portfolios.ids' => SimpleParam::PortfoliosIds,
          'any_projects.ids' => SimpleParam::AnyProjectsIds,
          'not_projects.ids' => SimpleParam::NotProjectsIds,
          'completion' => SimpleParam::Completion,
          'not_tags.ids' => SimpleParam::NotTagsIds,
          'any_tags.ids' => SimpleParam::AnyTagsIds,
          'subtask' => SimpleParam::Subtask,
          'sort' => SimpleParam::Sort,
          'milestone' => SimpleParam::Milestone,
          'searched_type' => SimpleParam::SearchedType,
        }.freeze
        private_constant :ARGS

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        # @sg-ignore
        # @param key [String] the name of the search url param
        # @param values [Array<String>] the values of the search url param
        # @return [Hash{String => String}] the converted params
        def convert_arg(key, values)
          # @type [Class<SimpleParam::SimpleParam>]
          clazz = ARGS.fetch(key)
          # @sg-ignore
          # @type [SimpleParam::SimpleParam]
          obj = clazz.new(key:, values:)
          # @sg-ignore
          obj.convert
        end

        # @return [Hash{String => Array<String}>]
        attr_reader :simple_url_params
      end
    end
  end
end
