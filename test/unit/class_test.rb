# typed: false
# frozen_string_literal: true

require_relative 'test_helper'

# Test a class that uses initializer mocks.
class ClassTest < Minitest::Test
  # obj = get_test_object(SomeClass) do
  #    # Go ahead and use concrete value for constructor arg
  #    @mocks[:some_constructor_arg] = 123
  # end
  #
  # @return [MyOpenStruct]
  attr_reader :mocks

  # @generic T
  # @param clazz [Class<generic<T>> & #new]
  # @return [generic<T>]
  def get_test_object(clazz, &twiddle_mocks)
    @mocks = get_initializer_mocks(clazz,
                                   respond_like_instance_of:,
                                   respond_like:)
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

  # @return [Hash{Symbol => Class}, nil]
  def respond_like_instance_of
    nil
  end

  # @return [Hash{Symbol => Class}, nil]
  def respond_like
    nil
  end

  # @generic T
  # @param clazz [Class<generic<T>> & #new]
  # @return [generic<T>]
  # @sg-ignore tool-limitation:new-duck-type-infers-enclosing-class
  #   Declared return type generic<T> does not match inferred type
  #   ClassTest for ClassTest#create_object. Dispatching #new through a
  #   Class<generic<T>> & #new duck-type intersection resolves to the
  #   enclosing class (ClassTest) rather than binding T or failing to
  #   infer -- a confidently wrong inference, not a missing one. Not
  #   yet filed upstream.
  def create_object(clazz)
    clazz.new(**@mocks.to_h)
  end
end
