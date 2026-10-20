# typed: false
# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/requested_fields'

class TestRequestedFields < ClassTest
  typed_mock :task, Asana::Resources::Task
  typed_mock :section, Asana::Resources::Section

  # @return [void]
  def test_memberships_or_raise
    memberships = [{ 'project' => { 'gid' => '1' } }]
    task.expects(:memberships).returns(memberships)

    assert_equal(memberships, Checkoff::Internal::RequestedFields.memberships_or_raise(task))
  end

  # @return [void]
  def test_memberships_or_raise_not_requested
    task.expects(:memberships).returns(nil)
    task.expects(:gid).returns('123')

    e = assert_raises(RuntimeError) { Checkoff::Internal::RequestedFields.memberships_or_raise(task) }

    assert_equal("memberships not found on task 123 - did you add 'memberships' in your extra_fields argument?",
                 e.message)
  end

  # @return [void]
  def test_section_project_or_raise
    project = { 'gid' => '1' }
    section.expects(:project).returns(project)

    assert_equal(project, Checkoff::Internal::RequestedFields.section_project_or_raise(section))
  end

  # @return [void]
  def test_section_project_or_raise_not_requested
    section.expects(:project).returns(nil)
    section.expects(:gid).returns('123')

    e = assert_raises(RuntimeError) { Checkoff::Internal::RequestedFields.section_project_or_raise(section) }

    assert_equal("project not found on section 123 - did you add 'project' in your extra_fields argument?",
                 e.message)
  end
end
