# frozen_string_literal: true

require_relative 'section/function_evaluator'

module Checkoff
  module SelectorClasses
    # Section selector classes
    module Section
      # :ends_with_milestone function
      class EndsWithMilestoneFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :ends_with_milestone

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param section [Asana::Resources::Section]
        #
        # @sg-ignore
        # @return [Boolean]
        def evaluate(section)
          tasks = client.tasks.get_tasks(section: section.gid,
                                         per_page: 100,
                                         options: { fields: ['resource_subtype'] })
          # @sg-ignore
          tasks.last&.resource_subtype == 'milestone'
        end
      end

      # :has_tasks? function
      class HasTasksPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :has_tasks?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param section [Asana::Resources::Section]
        #
        # @sg-ignore
        # @return [Boolean]
        def evaluate(section)
          @sections.tasks_by_section_gid(section.gid).any?
        end
      end
    end
  end
end
