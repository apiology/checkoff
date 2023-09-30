# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/project_selectors'

class TestProjectSelectors < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::ProjectSelectors]
  #  def get_test_object; end

  # @sg-ignore
  let_mock :project

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_false
    custom_field = {
      'name' => 'Project attributes',
      'multi_enum_values' => [],
    }
    project_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_values_contain_any_value, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true
    custom_field = {
      'name' => 'Project attributes',
      'multi_enum_values' => [{ 'name' => 'timeline' }],
    }
    project_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_values_contain_any_value, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_no_custom_field_false
    project_selectors = get_test_object do
      custom_fields = []
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_values_contain_any_value, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_bogus_raises
    project_selectors = get_test_object

    e = assert_raises(RuntimeError) { project_selectors.filter_via_project_selector(project, [:bogus]) }

    assert_match(/Teach me how to evaluate/, e.message)
  end

  # @return [Class<Checkoff::ProjectSelectors>]
  def class_under_test
    Checkoff::ProjectSelectors
  end
end
