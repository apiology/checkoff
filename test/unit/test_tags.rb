# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestTags < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client)

  let_mock :workspace_name, :tag_name, :tag, :workspace, :workspace_gid,
           :tags_api, :wrong_tag, :wrong_tag_name

  def test_tag_or_raise_raises
    tags = get_test_object do
      tag_arr = [wrong_tag]
      expect_tags_pulled(tag_arr)
    end
    assert_raises(RuntimeError) do
      tags.tag_or_raise(workspace_name, tag_name)
    end
  end

  def test_tag_or_raise
    tags = get_test_object do
      tag_arr = [wrong_tag, tag]
      expect_tags_pulled(tag_arr)
    end
    assert_equal(tag, tags.tag_or_raise(workspace_name, tag_name))
  end

  def expect_workspace_pulled
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
    workspace.expects(:gid).returns(workspace_gid)
  end

  def allow_tags_named
    wrong_tag.expects(:name).returns(wrong_tag_name).at_least(0)
    tag.expects(:name).returns(tag_name).at_least(0)
  end

  def expect_tags_pulled(tag_arr)
    expect_workspace_pulled
    client.expects(:tags).returns(tags_api)
    tags_api.expects(:get_tags_for_workspace).returns(tag_arr)
    allow_tags_named
  end

  def test_tag
    tags = get_test_object do
      tag_arr = [wrong_tag, tag]
      expect_tags_pulled(tag_arr)
    end
    assert_equal(tag, tags.tag(workspace_name, tag_name))
  end

  def class_under_test
    Checkoff::Tags
  end
end
