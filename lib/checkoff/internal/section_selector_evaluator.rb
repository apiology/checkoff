# typed: true
# frozen_string_literal: true

require_relative 'selector_classes/common'
require_relative 'selector_classes/section'
require_relative 'selector_evaluator'

module Checkoff
  # Evaluates section selectors against a section
  class SectionSelectorEvaluator < SelectorEvaluator
    # @param section [Asana::Resources::Project]
    # @param client [Asana::Client]
    # @param projects [Checkoff::Projects]
    # @param sections [Checkoff::Sections]
    # @param custom_fields [Checkoff::CustomFields]
    def initialize(section:,
                   client:,
                   projects: Checkoff::Projects.new(client: client),
                   sections: Checkoff::Sections.new(client: client),
                   custom_fields: Checkoff::CustomFields.new(client: client),
                   **_kwargs)
      @item = section
      @client = client
      @projects = projects
      @sections = sections
      @custom_fields = custom_fields
      super()
    end

    private

    COMMON_FUNCTION_EVALUATORS = (Checkoff::SelectorClasses::Common.constants.map do |const|
      Checkoff::SelectorClasses::Common.const_get(const)
    end - [Checkoff::SelectorClasses::Common::FunctionEvaluator]).freeze

    SECTION_FUNCTION_EVALUATORS = (Checkoff::SelectorClasses::Section.constants.map do |const|
      Checkoff::SelectorClasses::Section.const_get(const)
    end - [Checkoff::SelectorClasses::Section::FunctionEvaluator]).freeze

    FUNCTION_EVALUTORS = (COMMON_FUNCTION_EVALUATORS + SECTION_FUNCTION_EVALUATORS).freeze

    # @return [Array<Class<Checkoff::SelectorClasses::Project::FunctionEvaluator>>]
    def function_evaluators
      FUNCTION_EVALUTORS
    end

    # @return [Hash]
    def initializer_kwargs
      { sections: sections, projects: projects, client: client, custom_fields: custom_fields }
    end

    # @return [Asana::Resources::Project]
    attr_reader :item
    # @return [Checkoff::Sections]
    attr_reader :sections
    # @return [Checkoff::Projects]
    attr_reader :projects
    # @return [Checkoff::CustomFields]
    attr_reader :custom_fields
    # @return [Asana::Client]
    attr_reader :client
  end
end
