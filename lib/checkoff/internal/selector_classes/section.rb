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
        # @sg-ignore needs-yard-annotation
        #   Asana::ProxiedResourceClasses::Task#get_tasks has no @!parse stub in
        #   config/annotations_asana.rb, so its return type is fully unresolved ("Unresolved
        #   call to last" when T.unsafe is removed) — the T.unsafe here isn't papering over a
        #   Boolean-inference gap, it's working around this missing stub
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
        # @return [Boolean]
        def evaluate(section)
          sections.tasks_by_section_gid(section.gid).any?
        end
      end
    end
  end
end
