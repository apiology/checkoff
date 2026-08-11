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
        # @sg-ignore tool-limitation:generic-collection-last-dispatch
        #   Checkoff::SelectorClasses::Section::EndsWithMilestoneFunctionEvaluator#evaluate
        #   return type could not be inferred. Not the kwarg-call-resolution gap this marker
        #   originally cited (disproven: get_tasks's stub call resolves fine on its own once
        #   its @return was corrected from Enumerable<Task> to
        #   Asana::Resources::Collection<Asana::Resources::Task>, confirmed by returning
        #   `tasks` bare with no further chaining). Not &. either (disproven: plain `.` fails
        #   identically). The real gap is generics binding: Asana::Resources::Collection is
        #   now correctly annotated `@generic T` / `def last; # @return [generic<T>, nil]`
        #   (matches the real gem, which has no @return on #last at all), and get_tasks's
        #   stub now declares the parameterized `Collection<Task>` -- but T still doesn't
        #   bind through the @!parse-declared stub at the call site. A hardcoded
        #   `@return [Asana::Resources::Task, nil]` on Collection#last does clear this call
        #   site, confirming the mechanism, but would be wrong for this class's many other
        #   Collection<X> usages (Project, Tag, Workspace, etc.), so isn't applied. Same
        #   generics-dispatch limitation family as generic-class-new-dispatch and
        #   generic-method-overloading elsewhere in this codebase.
        def evaluate(section)
          tasks = client.tasks.get_tasks(section: section.gid,
                                         per_page: 100,
                                         options: { fields: ['resource_subtype'] })
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
        # @return [Boolean]
        def evaluate(section)
          sections.tasks_by_section_gid(section.gid).any?
        end
      end
    end
  end
end
