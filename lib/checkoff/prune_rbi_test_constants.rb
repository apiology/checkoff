# typed: true
# frozen_string_literal: true

module Checkoff
  # Remove TIME_BY_PERIOD redeclarations Sord emits on BaseAsana test subclasses.
  module PruneRbiTestConstants
    SUBCLASSES = %w[TestTasks TestProjects TestSections TestWorkspaces].freeze

    # @param klass [String]
    # @return [Regexp]
    def self.pattern_for(klass)
      /
        ^(class\ #{klass}\ <\ BaseAsana\n
        (?:(?!^class\ ).*\n)*?
        ^\ \ extend\ Forwardable\n)
        \ \ TIME_BY_PERIOD\ =\ T\.let\(\{\n
        (?:.*\n)*?
        ^\ \ \}\.freeze,\ T\.untyped\)\n
      /mx
    end

    # @param path [String]
    # @return [void]
    def self.call(path)
      content = File.read(path)
      text = prune_subclasses(content)
      return if text == content

      File.write(path, text)
      warn "Pruned duplicate TIME_BY_PERIOD blocks in #{path}"
    end

    # @param content [String]
    # @return [String]
    def self.prune_subclasses(content)
      text = content
      SUBCLASSES.each { |klass| text = text.gsub(pattern_for(klass), '\\1') }
      text
    end
  end
end
