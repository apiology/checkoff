# typed: false
# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/task_timing'

class TestTaskTiming < ClassTest
  # @!parse
  #  # @return [Checkoff::Internal::TaskTiming]
  #  def get_test_object; end

  let_mock :task
  # @return [void]
  def test_date_or_time_field_by_name_raises_if_unknown_field
    task_timing = get_test_object
    # @sg-ignore Wrong argument type for Checkoff::Internal::TaskTiming#date_or_time_field_by_name: task
    #   expected Asana::Resources::Task, received Mocha::Mock
    # https://github.com/castwide/solargraph/issues/1229
    e = assert_raises(RuntimeError) { task_timing.date_or_time_field_by_name(task, :blah) }

    assert_equal 'Teach me how to handle field :blah', e.message
  end

  # @return [void]
  def class_under_test
    Checkoff::Internal::TaskTiming
  end

  def respond_like_instance_of
    {
      client: Asana::Client,
      custom_fields: Checkoff::CustomFields,
    }
  end

  # @return [void]
  def respond_like
    {
      time_class: Time,
      date_class: Date,
    }
  end
end
