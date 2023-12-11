# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/project_timing'

class TestProjectTiming < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :custom_fields)

  let_mock :project, :custom_field_name

  def test_date_or_time_field_by_name_due
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      project.expects(:due_on).returns('2020-01-23').at_least_once
    end

    assert_equal(Date.new(2020, 1, 23), project_timing.date_or_time_field_by_name(project, :due))
  end

  def test_date_or_time_field_by_name_due_nil
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      project.expects(:due_on).returns(nil).at_least_once
    end

    assert_nil(project_timing.date_or_time_field_by_name(project, :due))
  end

  def test_date_or_time_field_by_name_start
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      project.expects(:start_on).returns('2020-01-23').at_least_once
    end

    assert_equal(Date.new(2020, 1, 23), project_timing.date_or_time_field_by_name(project, :start))
  end

  def test_date_or_time_field_by_name_start_nil
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      project.expects(:start_on).returns(nil).at_least_once
    end

    assert_nil(project_timing.date_or_time_field_by_name(project, :start))
  end

  def test_date_or_time_field_by_name_ready
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      project.expects(:start_on).returns('2020-01-23').at_least_once
    end

    assert_equal(Date.new(2020, 1, 23), project_timing.date_or_time_field_by_name(project, :ready))
  end

  def test_date_or_time_field_by_name_custom_field
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      resource_custom_field = {
        'display_value' => '2020-01-23 01:23:00 -0500',
      }
      custom_fields.expects(:resource_custom_field_by_name_or_raise).with(project,
                                                                          custom_field_name)
        .returns(resource_custom_field)
    end

    assert_equal(Time.parse('2020-01-23 01:23:00 -0500'),
                 project_timing.date_or_time_field_by_name(project,
                                                           [:custom_field,
                                                            custom_field_name]))
  end

  def test_date_or_time_field_by_name_custom_field_nil
    project_timing = get_test_object do
      @mocks[:date_class] = Date
      resource_custom_field = {
        'display_value' => nil,
      }
      custom_fields.expects(:resource_custom_field_by_name_or_raise).with(project,
                                                                          custom_field_name)
        .returns(resource_custom_field)
    end

    assert_nil(project_timing.date_or_time_field_by_name(project,
                                                         [:custom_field,
                                                          custom_field_name]))
  end

  def test_date_or_time_field_by_name_raises_if_unknown_field
    project_timing = get_test_object
    e = assert_raises(RuntimeError) { project_timing.date_or_time_field_by_name(project, :blah) }

    assert_equal 'Teach me how to handle field :blah', e.message
  end

  def test_date_or_time_field_by_name_raises_if_unknown_array_field
    project_timing = get_test_object
    e = assert_raises(RuntimeError) { project_timing.date_or_time_field_by_name(project, [:blah]) }

    assert_equal 'Teach me how to handle field [:blah]', e.message
  end

  def class_under_test
    Checkoff::Internal::ProjectTiming
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
