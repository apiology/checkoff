# frozen_string_literal: true
# typed: strict

# Solargraph typing for Overcommit hook subprocess helpers.
#
# @!parse
#   class Overcommit::Hook::Base
#     # @param cmd [Array<String>, String]
#     # @param options [Hash]
#     # @return [Overcommit::Subprocess::Result]
#     def execute(cmd, options = {}); end
#   end
