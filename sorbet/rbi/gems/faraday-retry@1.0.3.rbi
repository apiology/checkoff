# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `faraday-retry` gem.
# Please instead update this file by running `bin/tapioca gem faraday-retry`.


# Faraday namespace.
#
# source://faraday-retry//lib/faraday/retriable_response.rb#4
module Faraday
  class << self
    # source://faraday/1.10.4/lib/faraday.rb#81
    def default_adapter; end

    # source://faraday/1.10.4/lib/faraday.rb#137
    def default_adapter=(adapter); end

    # source://faraday/1.10.4/lib/faraday.rb#155
    def default_connection; end

    # source://faraday/1.10.4/lib/faraday.rb#84
    def default_connection=(_arg0); end

    # source://faraday/1.10.4/lib/faraday.rb#162
    def default_connection_options; end

    # source://faraday/1.10.4/lib/faraday.rb#169
    def default_connection_options=(options); end

    # source://faraday/1.10.4/lib/faraday.rb#89
    def ignore_env_proxy; end

    # source://faraday/1.10.4/lib/faraday.rb#89
    def ignore_env_proxy=(_arg0); end

    # source://faraday/1.10.4/lib/faraday.rb#72
    def lib_path; end

    # source://faraday/1.10.4/lib/faraday.rb#72
    def lib_path=(_arg0); end

    # source://faraday/1.10.4/lib/faraday.rb#118
    def new(url = T.unsafe(nil), options = T.unsafe(nil), &block); end

    # source://faraday/1.10.4/lib/faraday.rb#128
    def require_lib(*libs); end

    # source://faraday/1.10.4/lib/faraday.rb#128
    def require_libs(*libs); end

    # source://faraday/1.10.4/lib/faraday.rb#142
    def respond_to_missing?(symbol, include_private = T.unsafe(nil)); end

    # source://faraday/1.10.4/lib/faraday.rb#68
    def root_path; end

    # source://faraday/1.10.4/lib/faraday.rb#68
    def root_path=(_arg0); end

    private

    # source://faraday/1.10.4/lib/faraday.rb#178
    def method_missing(name, *args, &block); end
  end
end

# Exception used to control the Retry middleware.
#
# source://faraday-retry//lib/faraday/retriable_response.rb#6
class Faraday::RetriableResponse < ::Faraday::Error; end

# Middleware main module.
#
# source://faraday-retry//lib/faraday/retry/middleware.rb#4
module Faraday::Retry; end

# This class provides the main implementation for your middleware.
# Your middleware can implement any of the following methods:
# * on_request - called when the request is being prepared
# * on_complete - called when the response is being processed
#
# Optionally, you can also override the following methods from Faraday::Middleware
# * initialize(app, options = {}) - the initializer method
# * call(env) - the main middleware invocation method.
#   This already calls on_request and on_complete, so you normally don't need to override it.
#   You may need to in case you need to "wrap" the request or need more control
#   (see "retry" middleware: https://github.com/lostisland/faraday/blob/main/lib/faraday/request/retry.rb#L142).
#   IMPORTANT: Remember to call `@app.call(env)` or `super` to not interrupt the middleware chain!
#
# source://faraday-retry//lib/faraday/retry/middleware.rb#17
class Faraday::Retry::Middleware < ::Faraday::Middleware
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @param app [#call]
  # @param options [Hash]
  # @return [Middleware] a new instance of Middleware
  #
  # source://faraday-retry//lib/faraday/retry/middleware.rb#114
  def initialize(app, options = T.unsafe(nil)); end

  # An exception matcher for the rescue clause can usually be any object
  # that responds to `===`, but for Ruby 1.8 it has to be a Class or Module.
  #
  # @api private
  # @param exceptions [Array]
  # @return [Module] an exception matcher
  #
  # source://faraday-retry//lib/faraday/retry/middleware.rb#166
  def build_exception_matcher(exceptions); end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#120
  def calculate_sleep_amount(retries, env); end

  # @param env [Faraday::Env]
  #
  # source://faraday-retry//lib/faraday/retry/middleware.rb#134
  def call(env); end

  private

  # MDN spec for Retry-After header:
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After
  #
  # source://faraday-retry//lib/faraday/retry/middleware.rb#203
  def calculate_retry_after(env); end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#218
  def calculate_retry_interval(retries); end

  # @return [Boolean]
  #
  # source://faraday-retry//lib/faraday/retry/middleware.rb#187
  def retry_request?(env, exception); end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#192
  def rewind_files(body); end
end

# source://faraday-retry//lib/faraday/retry/middleware.rb#18
Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS = T.let(T.unsafe(nil), Array)

# source://faraday-retry//lib/faraday/retry/middleware.rb#22
Faraday::Retry::Middleware::IDEMPOTENT_METHODS = T.let(T.unsafe(nil), Array)

# Options contains the configurable parameters for the Retry middleware.
#
# source://faraday-retry//lib/faraday/retry/middleware.rb#29
class Faraday::Retry::Middleware::Options < ::Faraday::Options
  # source://faraday-retry//lib/faraday/retry/middleware.rb#57
  def backoff_factor; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#61
  def exceptions; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#45
  def interval; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#53
  def interval_randomness; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#41
  def max; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#49
  def max_interval; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#65
  def methods; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#73
  def retry_block; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#69
  def retry_if; end

  # source://faraday-retry//lib/faraday/retry/middleware.rb#77
  def retry_statuses; end

  class << self
    # source://faraday-retry//lib/faraday/retry/middleware.rb#33
    def from(value); end
  end
end

# source://faraday-retry//lib/faraday/retry/middleware.rb#31
Faraday::Retry::Middleware::Options::DEFAULT_CHECK = T.let(T.unsafe(nil), Proc)

# source://faraday-retry//lib/faraday/retry/version.rb#5
Faraday::Retry::VERSION = T.let(T.unsafe(nil), String)
