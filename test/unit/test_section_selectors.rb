# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/section_selectors'

class TestSectionSelectors < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::SectionSelectors]
  #  def get_test_object; end

  def_delegators(:@mocks, :client, :sections)

  let_mock :section

  let_mock :tasks

  let_mock :milestone

  # @return [void]
  def test_filter_via_ends_with_milestone_empty
    section_selectors = get_test_object do
      # @sg-ignore Unresolved call to client
      client.expects(:tasks).returns(tasks)
      # @sg-ignore Unresolved call to section
      section.expects(:gid).returns('1234')
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:get_tasks).with(section: '1234', per_page: 100,
                                     options: { fields: ['resource_subtype'] }).returns([])
    end

    # @sg-ignore Unresolved call to section
    refute(section_selectors.filter_via_section_selector(section,
                                                         [:ends_with_milestone]))
  end

  # @return [void]
  def expect_client_tasks_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:tasks).returns(tasks)
  end

  # @return [void]
  def expect_section_gid_pulled
    # @sg-ignore Unresolved call to section
    section.expects(:gid).returns('1234')
  end

  # @return [void]
  def mock_filter_via_ends_with_milestone_true
    expect_client_tasks_pulled
    expect_section_gid_pulled
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:get_tasks).with(section: '1234', per_page: 100,
                                   options: { fields: ['resource_subtype'] }).returns([milestone])
    # @sg-ignore Unresolved call to milestone
    milestone.expects(:resource_subtype).returns('milestone')
  end

  # @return [void]
  def test_filter_via_ends_with_milestone_true
    section_selectors = get_test_object do
      mock_filter_via_ends_with_milestone_true
    end

    # @sg-ignore Unresolved call to section
    assert(section_selectors.filter_via_section_selector(section,
                                                         [:ends_with_milestone]))
  end

  # @return [void]
  def test_bogus_raises
    section_selectors = get_test_object

    # @sg-ignore Unresolved call to section
    e = assert_raises(RuntimeError) { section_selectors.filter_via_section_selector(section, [:bogus]) }

    assert_match(/Syntax issue trying to handle/, e.message)
  end

  # @return [void]
  def test_filter_via_has_tasks_false
    section_selectors = get_test_object do
      expect_section_gid_pulled
      # @sg-ignore Unresolved call to sections
      sections.expects(:tasks_by_section_gid).with('1234').returns([])
    end

    # @sg-ignore Unresolved call to section
    refute(section_selectors.filter_via_section_selector(section,
                                                         [:has_tasks?]))
  end

  # @return [Class<Checkoff::SectionSelectors>]
  def class_under_test
    Checkoff::SectionSelectors
  end
end
