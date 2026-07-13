# typed: true
# frozen_string_literal: true

require 'stringio'
require 'checkoff/internal/logging'
require_relative '../test_helper'

class TestLogging < Minitest::Test
  # Named owner so Solargraph can resolve Logging#logger (Class.new blocks are opaque).
  class LoggerOwner
    include Logging
  end

  # @return [void]
  def test_logger_defaults_without_rails
    with_removed_rails do
      logger_owner = LoggerOwner.new

      logger = logger_owner.logger

      assert_instance_of(Logger, logger)
      assert_equal(Logger::WARN, logger.level)
    end
  end

  # @return [void]
  def test_logger_uses_rails_logger_when_available
    rails_logger = Logger.new(StringIO.new)
    rails_module = Module.new
    rails_module.define_singleton_method(:logger) { rails_logger }

    with_temporary_rails(rails_module) do
      logger_owner = LoggerOwner.new

      assert_same(rails_logger, logger_owner.logger)
    end
  end

  # @return [void]
  def test_logger_falls_back_when_rails_has_no_logger
    with_temporary_rails(Module.new) do
      logger_owner = LoggerOwner.new

      assert_instance_of(Logger, logger_owner.logger)
    end
  end

  private

  # @return [void]
  def with_removed_rails
    had_rails = Object.const_defined?(:Rails)
    original_rails = Object.const_get(:Rails) if had_rails
    Object.send(:remove_const, :Rails) if had_rails
    yield
  ensure
    Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)
    Object.const_set(:Rails, original_rails) if had_rails
  end

  # @param rails_const [Module]
  # @return [void]
  def with_temporary_rails(rails_const)
    with_removed_rails do
      Object.const_set(:Rails, rails_const)
      yield
    end
  end
end
