# typed: true
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/timing'

class TestTiming < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :today_getter)

  # @return [void]
  def test_in_period_this_week_date_true
    date = Date.parse('2019-01-04') # Friday
    timing = get_test_object do
      today_getter.expects(:today).returns(Date.new(2019, 1, 1)) # Tuesday
    end

    assert(timing.in_period?(date, :this_week))
  end

  # @return [void]
  def test_in_period_this_week_nil_true
    timing = get_test_object

    assert(timing.in_period?(nil, :this_week))
  end

  # @return [void]
  def test_in_period_day_of_week_nil_false
    timing = get_test_object

    refute(timing.in_period?(nil, :saturday))
  end

  # @return [void]
  def test_in_period_day_of_week_saturday_false
    date = Date.parse('2099-01-04')
    timing = get_test_object do
      today_getter.expects(:today).returns(Date.new(2019, 1, 1)) # Tuesday
    end

    refute(timing.in_period?(date, :saturday))
  end

  # @return [void]
  def test_in_period_indefinite_true
    date = Date.parse('2099-01-04')
    timing = get_test_object

    assert(timing.in_period?(date, :indefinite))
  end

  # @return [void]
  def test_in_period_bad_period
    date = Date.parse('2019-01-04') # Friday
    timing = get_test_object
    e = assert_raises(RuntimeError) { timing.in_period?(date, :invalid) }

    assert_equal('Teach me how to handle period :invalid', e.message)
  end

  # @return [void]
  def test_in_period_bad_compound_period
    date = Date.parse('2019-01-04') # Friday
    timing = get_test_object
    e = assert_raises(RuntimeError) { timing.in_period?(date, [:invalid, 123]) }

    assert_equal('Teach me how to handle period [:invalid, 123]', e.message)
  end

  # @return [void]
  def class_under_test
    Checkoff::Timing
  end

  def respond_like_instance_of
    {}
  end

  def respond_like
    {
      today_getter: Date,
      now_getter: Time,
    }
  end
end
