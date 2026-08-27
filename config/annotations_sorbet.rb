# typed: true
# frozen_string_literal: true

require 'sorbet-runtime'

# @!parse
#   module T
#     # @generic A
#     # @param arg [generic<A>, nil]
#     # @return [generic<A>]
#     def self.must(arg); end
#   end
