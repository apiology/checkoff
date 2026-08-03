# typed: true
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
        # @return [Boolean]
        # @sg-ignore tool-limitation:return-type-didnt-stick
        #   T.unsafe(tasks).last&.resource_subtype == 'milestone' as the tail expression still
        #   isn't recognized as satisfying the declared @return [Boolean] — T.unsafe disables
        #   checking on the receiver but Solargraph still flags the comparison's result type
        def evaluate(section)
          tasks = client.tasks.get_tasks(section: section.gid,
                                         per_page: 100,
                                         options: { fields: ['resource_subtype'] })
          T.unsafe(tasks).last&.resource_subtype == 'milestone'
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
        # @sg-ignore needs-yard-annotation
        #   Sections#tasks_by_section_gid's Enumerable<Task> element type doesn't propagate to
        #   the @return below
        # @return [Boolean]
        def evaluate(section)
          # @sg-ignore needs-yard-annotation
          #   same propagation gap on #any?
          @sections.tasks_by_section_gid(section.gid).any?
        end
      end
    end
  end
end
