# typed: false
# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/requested_fields'

class TestRequestedFields < ClassTest
  typed_mock :task, Asana::Resources::Task

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
end
