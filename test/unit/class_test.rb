# frozen_string_literal: true

require_relative 'test_helper'

# Test a class that uses initializer mocks.
class ClassTest < Minitest::Test
  # Implement 'class_under_test' returning the class name to be
  # initialized with keyword mocks
  def get_test_object(&twiddle_mocks)
    @mocks = get_initializer_mocks(class_under_test)
    yield @mocks if twiddle_mocks
    create_object
  end

  def create_object
    class_under_test.new(**@mocks.to_h)
  end
end
