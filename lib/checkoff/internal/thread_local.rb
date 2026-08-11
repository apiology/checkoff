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
      #   not be inferred. Correction to this marker's prior text: the ensure clause IS
      #   the cause after all. Re-isolated against the current pinned revision (which
      #   now includes #1274's bare-yield fix): a minimal @generic T method with
      #   @yieldreturn [generic<T>] and block.yield now type-checks clean on its own
      #   (both bare `yield` and explicit &block/block.yield forms), and adding back
      #   this method's params doesn't reintroduce the failure either -- but adding a
      #   bare `ensure` clause (even just `ensure; nil; end`, no reassignment) does,
      #   on an otherwise-identical minimal method. Not yet filed upstream under this
      #   more precise repro.
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
