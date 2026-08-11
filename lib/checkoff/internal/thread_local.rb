# typed: true
# frozen_string_literal: true

module Checkoff
  module Internal
    # Manage thread lock variables in a block
    class ThreadLocal
      # @generic T
      # @param name [Symbol]
      # @param value [Object,Boolean]
      # @yieldreturn [generic<T>]
      # @return [generic<T>]
      # @sg-ignore tool-limitation:pr-1274-follow-on
      #   https://github.com/castwide/solargraph/issues/1265
      #   Checkoff::Internal::ThreadLocal#with_thread_local_variable return type could
      #   not be inferred. https://github.com/castwide/solargraph/pull/1274's fix commit
      #   is already an ancestor of our pinned fork revision, but this call shape still
      #   reproduces -- that PR doesn't fully cover it. Confirmed the ensure clause isn't
      #   the cause via strip-and-observe (explicit result var + trailing return, no
      #   ensure, same failure at the same def line).
      def with_thread_local_variable(name, value, &block)
        old_value = Thread.current[name]
        Thread.current[name] = value
        block.yield
      ensure
        Thread.current[name] = old_value
      end
    end
  end
end
