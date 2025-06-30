# typed: false
# frozen_string_literal: true

require 'logger'

# include this to add ability to log at different levels
module Logging
  # @sg-ignore
  # @return [::Logger]
  def logger
    # @type [::Logger]
    # @sg-ignore
    @logger ||= if defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger
                  # @sg-ignore
                  # @type [::Logger]
                  Rails.logger
                else
                  ::Logger.new($stdout, level: log_level)
                end
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

  # @sg-ignore
  # @return [Symbol]
  def log_level
    # @sg-ignore
    ENV.fetch('LOG_LEVEL', 'INFO').downcase.to_sym
  end
end
