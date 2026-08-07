# typed: true
# frozen_string_literal: true

require 'overcommit'
require 'overcommit/hook/pre_commit/base'

# Overcommit configuration
module Overcommit
  module Hook
    module PreCommit
      # Runs `punchlist` against any modified Ruby files.
      class Punchlist < Base
        # @param stdout [String]
        # @return [Array<Overcommit::Hook::Message>]
        def parse_output(stdout)
          stdout.split("\n").map do |line|
            file, line_no, _message = line.split(':', 3)
            # @sg-ignore tool-limitation:struct-new-block-form
            #   Wrong argument type for Struct.new: fields expected Symbol, String, received
            #   Integer. Message.new(:error, file, line_no.to_i, line) is the block-form
            #   Struct subclass's generated initializer, but Solargraph resolves the call
            #   against Struct.new's own class-definition signature (Symbol/String field
            #   names) instead. Not yet filed upstream; same neighborhood as open
            #   castwide/solargraph#1268/#1269/#260 (general Struct support gaps).
            Overcommit::Hook::Message.new(:error, file, line_no.to_i, line)
          end
        end

        # @return [String]
        def files_glob
          "{" \
            "#{applicable_files.join(',')}" \
            "}"
        end

        # @return [Symbol, Array<Overcommit::Hook::Message>]
        def run
          # @type [Overcommit::Subprocess::Result]
          result = execute([*command, '-g', files_glob])

          warn result.stderr

          # If the command exited with a non-zero status or produced any output, treat it as a failure
          if result.status.nonzero? || !result.stdout.empty? || !result.stderr.empty?
            # Parse the output to create Message objects
            stdout = result.stdout
            messages = parse_output(stdout)

            return messages
          end

          :pass
        end
      end
    end
  end
end
