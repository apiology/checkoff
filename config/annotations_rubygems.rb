# frozen_string_literal: true
# typed: strict

# rbs's bundled core/rubygems signatures declare Gem::Specification.new's
# block param as untyped, so every call on the yielded spec in
# checkoff.gemspec's `Gem::Specification.new do |spec| ... end` block is
# unresolved even though the individual setters (name=, version=, etc.)
# already have their own signatures.
#
# @!parse
#   class Gem::Specification
#     # @param name [String, nil]
#     # @param version [String, nil]
#     # @yieldparam spec [Gem::Specification]
#     # @yieldreturn [void]
#     # @return [Gem::Specification]
#     def self.new(name = nil, version = nil); end
#   end
