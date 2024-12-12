# typed: strict
# frozen_string_literal: true

module Checkoff
  module Internal
    # Manage thread lock variables in a block
    class ThreadLocal
      # @sg-ignore
      # @param name [Symbol]
      # @param value [Object,Boolean]
      #
      # @return [Object,Boolean]
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
