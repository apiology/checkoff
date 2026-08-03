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
        # @sg-ignore tool-limitation:parse-stub-kwarg-return
        #   Asana::ProxiedResourceClasses::Task#get_tasks is declared via @!parse in
        #   config/annotations_asana.rb with a correct, complete @return tag, but calling a
        #   @!parse-declared method with keyword arguments never resolves its return type at the
        #   call site (confirmed in an isolated repro against plain upstream solargraph 0.60.2,
        #   with all kwargs passed and with a subset — same failure either way; the equivalent
        #   real Ruby method definition, not a @!parse stub, resolves fine) — T.unsafe works
        #   around this, not a missing/incomplete annotation
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
