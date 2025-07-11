# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `faraday-em_synchrony` gem.
# Please instead update this file by running `bin/tapioca gem faraday-em_synchrony`.


# source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#5
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

# source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#6
class Faraday::Adapter
  # source://faraday/1.10.4/lib/faraday/adapter.rb#33
  def initialize(_app = T.unsafe(nil), opts = T.unsafe(nil), &block); end

  # source://faraday/1.10.4/lib/faraday/adapter.rb#60
  def call(env); end

  # source://faraday/1.10.4/lib/faraday/adapter.rb#55
  def close; end

  # source://faraday/1.10.4/lib/faraday/adapter.rb#46
  def connection(env); end

  private

  # source://faraday/1.10.4/lib/faraday/adapter.rb#91
  def request_timeout(type, options); end

  # source://faraday/1.10.4/lib/faraday/adapter.rb#67
  def save_response(env, status, body, headers = T.unsafe(nil), reason_phrase = T.unsafe(nil)); end
end

# EventMachine Synchrony adapter.
#
# source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#8
class Faraday::Adapter::EMSynchrony < ::Faraday::Adapter
  include ::Faraday::Adapter::EMHttp::Options

  # source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#40
  def call(env); end

  # source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#82
  def create_request(env); end

  private

  # source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#135
  def call_block(block); end

  # source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#91
  def execute_parallel_request(env, request, http_method); end

  # source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#112
  def execute_single_request(env, request, http_method); end

  class << self
    # @return [ParallelManager]
    #
    # source://faraday-em_synchrony//lib/faraday/adapter/em_synchrony.rb#36
    def setup_parallel_manager(_options = T.unsafe(nil)); end
  end
end

# Main Faraday::EmSynchrony module
#
# source://faraday-em_synchrony//lib/faraday/em_synchrony/version.rb#4
module Faraday::EmSynchrony; end

# source://faraday-em_synchrony//lib/faraday/em_synchrony/version.rb#5
Faraday::EmSynchrony::VERSION = T.let(T.unsafe(nil), String)
