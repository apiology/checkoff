# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/task_timing'

class TestTaskTiming < ClassTest
  let_mock :task
  def test_date_or_time_field_by_name_raises_if_unknown_field
    task_timing = get_test_object
    e = assert_raises(RuntimeError) { task_timing.date_or_time_field_by_name(task, :blah) }

    assert_equal 'Teach me how to handle field blah', e.message
  end

  def class_under_test
    Checkoff::Internal::TaskTiming
  end

  def respond_like_instance_of
    {
      client: Asana::Client,
      custom_fields: Checkoff::CustomFields,
    }
  end

  def respond_like
    {
      time_class: Time,
      date_class: Date,
    }
  end
end
