# frozen_string_literal: true

require_relative 'test_helper'

# Test a class that uses initializer mocks.
class ClassTest < Minitest::Test
  # Implement 'class_under_test' returning the class name to be
  # initialized with keyword mocks
  #
  # obj = get_test_object do
  #    # Go ahead and use concrete value for constructor arg
  #    @mocks[:some_constructor_arg] = 123
  # end
  def get_test_object(clazz = class_under_test, &twiddle_mocks)
    @mocks = get_initializer_mocks(clazz,
                                   respond_like_instance_of: respond_like_instance_of,
                                   respond_like: respond_like)
    yield @mocks if twiddle_mocks
    create_object(clazz)
  rescue StandardError
    # if get_initializer_mocks raises and @mocks isn't set,
    # def_delegators later on gets super confused if it tries to
    # delegate to it and hides the real error
    @mocks = MyOpenStruct.new({})
    raise
  end

  # default to telling get_initailizer_mocks not to validate this.
  # things going forward using create-test.sh should default to
  # setting this to non-nil values, which are validated and require
  # setting a full hash of values

  def respond_like_instance_of
    nil
  end

  def respond_like
    nil
  end

  def create_object(clazz = class_under_test)
    clazz.new(**@mocks.to_h)
  end
end
