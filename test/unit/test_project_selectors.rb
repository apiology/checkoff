# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/project_selectors'

class TestProjectSelectors < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :client, :projects)

  # @!parse
  #  # @return [Checkoff::ProjectSelectors]
  #  def get_test_object; end

  # @sg-ignore
  let_mock :project

  # @return [void]
  def test_filter_via_custom_field_value_contain_any_value_false
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [],
      'display_value' => 'something else',
    }
    project_selectors = get_test_object do
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client: client)
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [{ 'name' => 'timeline', 'enabled' => true }],
      'display_value' => 'timeline',
    }
    project_selectors = get_test_object do
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client: client)
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true_single_in_multi_enum
    custom_field = {
      'name' => 'Project attributes',
      'enabled' => true,
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [{ 'name' => 'timeline' }],
      'display_value' => 'timeline',
    }
    project_selectors = get_test_object do
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client: client)
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true_multiple
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [
        { 'name' => 'timeline', 'enabled' => true },
        { 'name' => 'something else', 'enabled' => true },
      ],
      'display_value' => 'timeline,something else',
    }
    project_selectors = get_test_object do
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client: client)
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_false_nothing_set
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [],
      'display_value' => 'timeline,something else',
    }
    project_selectors = get_test_object do
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client: client)
      custom_fields = [custom_field]
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_value_contains_any_value_no_custom_field_false
    project_selectors = get_test_object do
      @mocks[:custom_fields] = Checkoff::CustomFields.new(client: client)
      custom_fields = []
      # @sg-ignore
      project.expects(:custom_fields).returns(custom_fields).at_least(1)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_due_date_false
    project_selectors = get_test_object do
      # @sg-ignore
      project.expects(:due_date).returns('2099-01-01').at_least(1)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:nil?, [:due_date]]))
  end

  # @return [void]
  def test_filter_via_ready_false
    project_selectors = get_test_object do
      projects.expects(:project_ready?).with(project, period: :now_or_before)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:ready?]))
  end

  # @return [void]
  def test_bogus_raises
    project_selectors = get_test_object

    e = assert_raises(RuntimeError) { project_selectors.filter_via_project_selector(project, [:bogus]) }

    assert_match(/Syntax issue trying to handle/, e.message)
  end

  # @return [Class<Checkoff::ProjectSelectors>]
  def class_under_test
    Checkoff::ProjectSelectors
  end
end
