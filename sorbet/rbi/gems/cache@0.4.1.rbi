# typed: strict

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `cache` gem.
# Please instead update this file by running `bin/tapioca gem cache`.


# source://cache//lib/cache/config.rb#1
class Cache
  # @return [Cache] a new instance of Cache
  #
  # source://cache//lib/cache.rb#29
  def initialize(metal = T.unsafe(nil)); end

  # Get the current value (if any), pass it into a block, and set the result.
  #
  # Example:
  #     cache.cas 'hello' { |current| 'world' }
  #
  # source://cache//lib/cache.rb#151
  def cas(k, ttl = T.unsafe(nil), &blk); end

  # Flush the cache.
  #
  # Example:
  #     cache.flush
  #
  # source://cache//lib/cache.rb#95
  def clear; end

  # Get the current value (if any), pass it into a block, and set the result.
  #
  # Example:
  #     cache.cas 'hello' { |current| 'world' }
  #
  # source://cache//lib/cache.rb#151
  def compare_and_swap(k, ttl = T.unsafe(nil), &blk); end

  # Returns the value of attribute config.
  #
  # source://cache//lib/cache.rb#23
  def config; end

  # Decrement a value.
  #
  # Example:
  #     cache.decrement 'high-fives'
  #
  # source://cache//lib/cache.rb#126
  def decrement(k, amount = T.unsafe(nil), ignored_options = T.unsafe(nil)); end

  # Delete a value.
  #
  # Example:
  #     cache.delete 'hello'
  #
  # source://cache//lib/cache.rb#86
  def delete(k, ignored_options = T.unsafe(nil)); end

  # Check if something exists.
  #
  # Example:
  #     cache.exist? 'hello'
  #
  # @return [Boolean]
  #
  # source://cache//lib/cache.rb#106
  def exist?(k, ignored_options = T.unsafe(nil)); end

  # Try to get a value and if it doesn't exist, set it to the result of the block.
  #
  # Accepts :expires_in for compatibility with Rails.
  #
  # Example:
  #     cache.fetch 'hello' { 'world' }
  #
  # source://cache//lib/cache.rb#136
  def fetch(k, ttl = T.unsafe(nil), &blk); end

  # Flush the cache.
  #
  # Example:
  #     cache.flush
  #
  # source://cache//lib/cache.rb#95
  def flush; end

  # Get a value.
  #
  # Example:
  #     cache.get 'hello'
  #
  # source://cache//lib/cache.rb#54
  def get(k, ignored_options = T.unsafe(nil)); end

  # Get multiple cache entries.
  #
  # Example:
  #     cache.get_multi 'hello', 'privyet'
  #
  # source://cache//lib/cache.rb#65
  def get_multi(*ks); end

  # Increment a value.
  #
  # Example:
  #     cache.increment 'high-fives'
  #
  # source://cache//lib/cache.rb#115
  def increment(k, amount = T.unsafe(nil), ignored_options = T.unsafe(nil)); end

  # For compatibility with Rails 2.x
  #
  # source://cache//lib/cache.rb#27
  def logger; end

  # For compatibility with Rails 2.x
  #
  # source://cache//lib/cache.rb#27
  def logger=(_arg0); end

  # Returns the value of attribute metal.
  #
  # source://cache//lib/cache.rb#24
  def metal; end

  # Get a value.
  #
  # Example:
  #     cache.get 'hello'
  #
  # source://cache//lib/cache.rb#54
  def read(k, ignored_options = T.unsafe(nil)); end

  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  #
  # source://cache//lib/cache.rb#75
  def set(k, v, ttl = T.unsafe(nil), ignored_options = T.unsafe(nil)); end

  # Get stats.
  #
  # Example:
  #     cache.stats
  #
  # source://cache//lib/cache.rb#167
  def stats; end

  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  #
  # source://cache//lib/cache.rb#75
  def write(k, v, ttl = T.unsafe(nil), ignored_options = T.unsafe(nil)); end

  private

  # source://cache//lib/cache.rb#181
  def after_fork; end

  # source://cache//lib/cache.rb#185
  def extract_ttl(ttl); end

  # source://cache//lib/cache.rb#174
  def handle_fork; end

  class << self
    # Create a new Cache instance by wrapping a client of your choice.
    #
    # Defaults to an in-process memory store.
    #
    # Supported memcached clients:
    # * memcached[https://github.com/evan/memcached] (either a Memcached or a Memcached::Rails)
    # * dalli[https://github.com/mperham/dalli] (either a Dalli::Client or an ActiveSupport::Cache::DalliStore)
    # * memcache-client[https://github.com/mperham/memcache-client] (MemCache, the one commonly used by Rails)
    #
    # Supported Redis clients:
    # * redis[https://github.com/ezmobius/redis-rb]
    #
    # Example:
    #     raw_client = Memcached.new('127.0.0.1:11211')
    #     cache = Cache.wrap raw_client
    #
    # source://cache//lib/cache.rb#19
    def wrap(metal = T.unsafe(nil)); end
  end
end

# Here's where config options are kept.
#
# Example:
#     cache.config.default_ttl = 120 # seconds
#
# source://cache//lib/cache/config.rb#6
class Cache::Config
  # source://cache//lib/cache/config.rb#15
  def default_ttl; end

  # TTL for method caches. Defaults to 60 seconds.
  #
  # Example:
  #     cache.config.default_ttl = 120 # seconds
  #
  # source://cache//lib/cache/config.rb#11
  def default_ttl=(seconds); end
end
