# typed: true
# frozen_string_literal: true

# double to inject cache_method, pretending to be cache_method gem
class Class
  # @param method_id [Symbol, String]
  # @param _ttl [Numeric, nil]
  # @return [void]
  def cache_method(method_id, _ttl = nil)
    instance_method(method_id) # ensure method at least exists; will raise if not
  end
end

# double to inject cache_method_clear, pretending to be cache_method gem
module Kernel
  # @param _method_id [Symbol, String]
  # @return [void]
  def cache_method_clear(_method_id)
    # do nothing
  end
end
