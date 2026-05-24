# typed: true
# frozen_string_literal: true

require 'logger'

# include this to add ability to log at different levels
module Logging
  # @return [::Logger]
  def logger
    # @type [::Logger]
    @logger ||= if Object.const_defined?(:Rails)
                  rails = Object.const_get(:Rails)
                  rails_logger = rails.respond_to?(:logger) ? rails.logger : nil
                  rails_logger || ::Logger.new($stdout, level: log_level)
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

  # @return [Symbol]
  # @sg-ignore
  def log_level
    # @sg-ignore
    # rubocop:disable Style/RedundantFetchBlock
    ENV.fetch('LOG_LEVEL') { 'INFO' }.downcase.to_sym
    # rubocop:enable Style/RedundantFetchBlock
  end
end
