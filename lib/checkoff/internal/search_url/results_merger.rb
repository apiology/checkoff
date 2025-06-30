# typed: false
# frozen_string_literal: true

module Checkoff
  module Internal
    module SearchUrl
      # Merge task selectors and search API arguments
      class ResultsMerger
        # @param args [Array<[Hash<String, String>]>]
        # @return [Hash<String, String>
        def self.merge_args(*args)
          # first element of args
          # @sg-ignore
          # @type [Hash<String, String>]
          f = args.fetch(0)
          # rest of args
          r = args.drop(0)
          f.merge(*r)
        end

        # @param task_selectors [Array<Array<[Symbol, Array]>>]
        # @return [Array(Symbol, Array, Array)]
        def self.merge_task_selectors(*task_selectors)
          return [] if task_selectors.empty?

          first_task_selector = task_selectors.fetch(0)

          return merge_task_selectors(*task_selectors.drop(1)) if first_task_selector.empty?

          return first_task_selector if task_selectors.length == 1

          rest_task_selectors = merge_task_selectors(*task_selectors.drop(1))

          return first_task_selector if rest_task_selectors.empty?

          [:and, first_task_selector, rest_task_selectors]
        end
      end
    end
  end
end
