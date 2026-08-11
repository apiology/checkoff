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
      # @sg-ignore tool-limitation:pr-1285
      #   https://github.com/castwide/solargraph/pull/1285
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
