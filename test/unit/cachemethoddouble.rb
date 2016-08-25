# frozen_string_literal: true
# double to inject cache_method, pretending to be cache_method gem
class Class
  def cache_method(_method_id, _ttl = nil)
    # do nothing
  end
end

# double to inject cache_method_clear, pretending to be cache_method gem
module Kernel
  def cache_method_clear(_method_id)
    # do nothing
  end
end
