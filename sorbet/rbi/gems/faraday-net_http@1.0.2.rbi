# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `faraday-net_http` gem.
# Please instead update this file by running `bin/tapioca gem faraday-net_http`.


# source://faraday-net_http//lib/faraday/adapter/net_http.rb#12
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

# source://faraday-net_http//lib/faraday/adapter/net_http.rb#13
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

# source://faraday-net_http//lib/faraday/adapter/net_http.rb#14
class Faraday::Adapter::NetHttp < ::Faraday::Adapter
  # @return [NetHttp] a new instance of NetHttp
  #
  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#37
  def initialize(app = T.unsafe(nil), opts = T.unsafe(nil), &block); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#42
  def build_connection(env); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#61
  def call(env); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#49
  def net_http_connection(env); end

  private

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#172
  def configure_request(http, req); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#156
  def configure_ssl(http, ssl); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#88
  def create_request(env); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#104
  def perform_request(http, env); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#134
  def request_via_get_method(http, env, &block); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#142
  def request_via_request_method(http, env, &block); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#125
  def request_with_wrapped_block(http, env, &block); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#192
  def ssl_cert_store(ssl); end

  # source://faraday-net_http//lib/faraday/adapter/net_http.rb#201
  def ssl_verify_mode(ssl); end
end

# source://faraday-net_http//lib/faraday/adapter/net_http.rb#35
Faraday::Adapter::NetHttp::NET_HTTP_EXCEPTIONS = T.let(T.unsafe(nil), Array)

# source://faraday-net_http//lib/faraday/net_http/version.rb#4
module Faraday::NetHttp; end

# source://faraday-net_http//lib/faraday/net_http/version.rb#5
Faraday::NetHttp::VERSION = T.let(T.unsafe(nil), String)
