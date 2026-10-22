# frozen_string_literal: true

require 'overcommit'
require 'overcommit/hook/pre_commit/base'

module Overcommit
  module Hook
    module PreCommit
      # Runs `steep check` against modified Ruby files.
      class Steep < Base
        MESSAGE_REGEX = /^(?<file>[^:\s]+):(?<line>\d+):\d+: \[\w+\] /

        # @return [Symbol, Array<Overcommit::Hook::Message>, Array(Symbol, String)]
        def run
          # @type [Overcommit::Subprocess::Result]
          result = execute(command, args: applicable_files)
          return :pass if result.success?

          output = result.stdout + result.stderr
          messages = extract_messages(output.lines.map(&:chomp).grep(MESSAGE_REGEX), MESSAGE_REGEX)
          return [:fail, output] if messages.empty?

          messages
        end
      end
    end
  end
end
