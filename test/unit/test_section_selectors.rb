# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/section_selectors'

class TestSectionSelectors < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::SectionSelectors]
  #  def get_test_object; end

  def_delegators(:@mocks, :client)

  # @sg-ignore
  let_mock :section

  let_mock :tasks

  let_mock :milestone

  # @return [void]
  def test_filter_via_custom_field_value_contain_any_value_false
    custom_field = {
      'name' => 'Section attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [],
      'display_value' => 'something else',
    }
    section_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      section.expects(:custom_fields).returns(custom_fields)
    end

    refute(section_selectors.filter_via_section_selector(section,
                                                         [:custom_field_value_contains_any_value, 'Section attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true
    custom_field = {
      'name' => 'Section attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [{ 'name' => 'timeline', 'enabled' => true }],
      'display_value' => 'timeline',
    }
    section_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      section.expects(:custom_fields).returns(custom_fields)
    end

    assert(section_selectors.filter_via_section_selector(section,
                                                         [:custom_field_value_contains_any_value, 'Section attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true_single_in_multi_enum
    custom_field = {
      'name' => 'Section attributes',
      'enabled' => true,
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [{ 'name' => 'timeline' }],
      'display_value' => 'timeline',
    }
    section_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      section.expects(:custom_fields).returns(custom_fields)
    end

    assert(section_selectors.filter_via_section_selector(section,
                                                         [:custom_field_value_contains_any_value, 'Section attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true_multiple
    custom_field = {
      'name' => 'Section attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [
        { 'name' => 'timeline', 'enabled' => true },
        { 'name' => 'something else', 'enabled' => true },
      ],
      'display_value' => 'timeline,something else',
    }
    section_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      section.expects(:custom_fields).returns(custom_fields)
    end

    assert(section_selectors.filter_via_section_selector(section,
                                                         [:custom_field_value_contains_any_value, 'Section attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_false_nothing_set
    custom_field = {
      'name' => 'Section attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [],
      'display_value' => 'timeline,something else',
    }
    section_selectors = get_test_object do
      custom_fields = [custom_field]
      # @sg-ignore
      section.expects(:custom_fields).returns(custom_fields)
    end

    refute(section_selectors.filter_via_section_selector(section,
                                                         [:custom_field_value_contains_any_value, 'Section attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_value_contains_any_value_no_custom_field_false
    section_selectors = get_test_object do
      custom_fields = []
      # @sg-ignore
      section.expects(:custom_fields).returns(custom_fields).at_least(1)
    end

    refute(section_selectors.filter_via_section_selector(section,
                                                         [:custom_field_value_contains_any_value, 'Section attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_ends_with_milestone_empty
    section_selectors = get_test_object do
      client.expects(:tasks).returns(tasks)
      section.expects(:gid).returns('1234')
      tasks.expects(:get_tasks).with(section: '1234', per_page: 100,
                                     options: { fields: ['resource_subtype'] }).returns([])
    end

    refute(section_selectors.filter_via_section_selector(section,
                                                         [:ends_with_milestone]))
  end

  # @return [void]
  def mock_filter_via_ends_with_milestone_true
    client.expects(:tasks).returns(tasks)
    section.expects(:gid).returns('1234')
    tasks.expects(:get_tasks).with(section: '1234', per_page: 100,
                                   options: { fields: ['resource_subtype'] }).returns([milestone])
    milestone.expects(:resource_subtype).returns('milestone')
  end

  # @return [void]
  def test_filter_via_ends_with_milestone_true
    section_selectors = get_test_object do
      mock_filter_via_ends_with_milestone_true
    end

    assert(section_selectors.filter_via_section_selector(section,
                                                         [:ends_with_milestone]))
  end

  # @return [void]
  def test_bogus_raises
    section_selectors = get_test_object

    e = assert_raises(RuntimeError) { section_selectors.filter_via_section_selector(section, [:bogus]) }

    assert_match(/Syntax issue trying to handle/, e.message)
  end

  # @return [Class<Checkoff::SectionSelectors>]
  def class_under_test
    Checkoff::SectionSelectors
  end
end
