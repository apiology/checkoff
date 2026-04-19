# typed: true
# frozen_string_literal: true

require 'logger'

# include this to add ability to log at different levels
module Logging
  # @sg-ignore
  # @return [::Logger]
  def logger
    # @type [::Logger]
    @logger ||= rails_logger || ::Logger.new($stdout, level: log_level)
  end

  # @param message [Object,nil]
  #
  # @return [void]
  def error(message = nil, &block)
    logger.error(message, &block)
  end

  # @param message [Object,nil]
  #
  # @return [void]
  def warn(message = nil, &block)
    logger.warn(message, &block)
  end

  # @param message [Object,nil]
  #
  # @return [void]
  def info(message = nil, &block)
    logger.info(message, &block)
  end

  # @param message [Object,nil]
  #
  # @return [void]
  def debug(message = nil, &block)
    logger.debug(message, &block)
  end

  # @param message [Object,nil]
  #
  # @return [void]
  def finer(message = nil, &block)
    # No such level by default
    #
    # logger.finer(message, &block)
  end

  private

  # @return [::Logger, nil]
  def rails_logger
    return nil unless Object.const_defined?(:Rails)

    rails = Object.const_get(:Rails)
    return nil unless rails.respond_to?(:logger)

    logger = rails.logger
    return nil unless logger.is_a?(::Logger)

    logger
  end

  # @sg-ignore
  # @return [Symbol]
  def log_level
    # @sg-ignore
    ENV.fetch('LOG_LEVEL', 'INFO').downcase.to_sym
  end
end
