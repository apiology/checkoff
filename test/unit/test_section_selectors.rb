# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/section_selectors'
require 'checkoff/internal/section_selector_evaluator'

class TestSectionSelectors < ClassTest
  typed_delegate :client, Asana::Client
  typed_delegate :sections, Checkoff::Sections

  typed_mock :section, Asana::Resources::Section
  typed_mock :tasks, Asana::ProxiedResourceClasses::Task
  typed_mock :milestone, Asana::Resources::Task

  # @return [void]
  def test_filter_via_ends_with_milestone_empty
    section_selectors = get_test_object(Checkoff::SectionSelectors) do
      client.expects(:tasks).returns(tasks)
      section.expects(:gid).returns('1234')
      tasks.expects(:get_tasks).with(section: '1234', per_page: 100,
                                     options: { fields: ['resource_subtype'] }).returns([])
    end

    refute(section_selectors.filter_via_section_selector(section,
                                                         [:ends_with_milestone]))
  end

  # @return [void]
  def expect_client_tasks_pulled
    client.expects(:tasks).returns(tasks)
  end

  # @return [void]
  def expect_section_gid_pulled
    section.expects(:gid).returns('1234')
  end

  # @return [void]
  def mock_filter_via_ends_with_milestone_true
    expect_client_tasks_pulled
    expect_section_gid_pulled
    tasks.expects(:get_tasks).with(section: '1234', per_page: 100,
                                   options: { fields: ['resource_subtype'] }).returns([milestone])
    milestone.expects(:resource_subtype).returns('milestone')
  end

  # @return [void]
  def test_filter_via_ends_with_milestone_true
    section_selectors = get_test_object(Checkoff::SectionSelectors) do
      mock_filter_via_ends_with_milestone_true
    end

    assert(section_selectors.filter_via_section_selector(section,
                                                         [:ends_with_milestone]))
  end

  # @return [void]
  def test_bogus_raises
    section_selectors = get_test_object(Checkoff::SectionSelectors)

    e = assert_raises(RuntimeError) { section_selectors.filter_via_section_selector(section, [:bogus]) }

    assert_match(/Syntax issue trying to handle/, e.message)
  end

  # @return [void]
  def test_filter_via_has_tasks_false
    section_selectors = get_test_object(Checkoff::SectionSelectors) do
      expect_section_gid_pulled
      sections.expects(:tasks_by_section_gid).with('1234').returns([])
    end

    refute(section_selectors.filter_via_section_selector(section,
                                                         [:has_tasks?]))
  end

  # @return [void]
  def test_evaluate_args_empty_selector_returns_empty_array
    evaluator = get_test_object(Checkoff::SectionSelectorEvaluator) do
      @mocks[:section] = section
    end

    # An empty Array selector makes selector[1..] return nil (Array#[]
    # with an open-ended range past the array's length); evaluate_args
    # guards against that rather than raising NoMethodError on .map.
    # @sg-ignore test-example
    #   deliberately calling the private method with a selector shape the
    #   public evaluate entrypoint never passes through (its own
    #   selector.empty? guard returns early first)
    assert_equal([], evaluator.send(:evaluate_args, [], nil))
  end
end
