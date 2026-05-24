# typed: true
# frozen_string_literal: true

require 'overcommit'
require 'overcommit/hook/pre_commit/base'

module Overcommit
  module Hook
    module PreCommit
      # Regenerates typechecking artifacts when Gemfile.lock is committed.
      class RegenerateTypecheck < Base
        # Tracked paths updated by `make build-typecheck` (see Makefile).
        BUILD_TYPECHECK_PATHS = [
          'sorbet/rbi/gems',
          'sorbet/rbi/annotations',
          'sorbet/rbi/dsl',
          'sorbet/rbi/todo.rbi',
          'rbs_collection.lock.yaml',
        ].freeze

        STAMP_FILES = %w[
          tapioca.installed
          Gemfile.lock.installed
          types.installed
        ].freeze

        # @return [Symbol, Array<Symbol, String>]
        def run
          execute(['rm', '-f', *STAMP_FILES])
          result = execute(%w[make build-typecheck])
          unless result.success?
            return [:fail, result.stdout + result.stderr]
          end

          stage_result = execute(['git', 'add', '-A', '--', *BUILD_TYPECHECK_PATHS])
          return :pass if stage_result.success?

          [:fail, stage_result.stdout + stage_result.stderr]
        end
      end
    end
  end
end
