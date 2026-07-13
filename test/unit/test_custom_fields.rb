# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class TestCustomFields < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client)

  let_mock :workspace_name, :custom_field_name, :custom_field, :workspace, :workspace_gid,
           :custom_fields_api, :wrong_custom_field, :wrong_custom_field_name

  # @return [void]
  def test_custom_field_or_raise_raises
    custom_fields = get_test_object do
      # @sg-ignore Unresolved call to wrong_custom_field
      custom_field_arr = [wrong_custom_field]
      expect_custom_fields_pulled(custom_field_arr)
    end
    assert_raises(RuntimeError) do
      # @sg-ignore Unresolved call to custom_field_or_raise
      custom_fields.custom_field_or_raise(workspace_name, custom_field_name)
    end
  end

  # @return [void]
  def test_custom_field_or_raise
    custom_fields = get_test_object do
      # @sg-ignore Unresolved call to wrong_custom_field
      # @sg-ignore Unresolved call to custom_field
      custom_field_arr = [wrong_custom_field, custom_field]
      expect_custom_fields_pulled(custom_field_arr)
    end

    # @sg-ignore Unresolved call to custom_field_or_raise
    # @sg-ignore Unresolved call to custom_field
    assert_equal(custom_field, custom_fields.custom_field_or_raise(workspace_name,
                                                                   custom_field_name))
  end

  # @return [void]
  def expect_workspace_pulled
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
    # @sg-ignore Unresolved call to workspace
    workspace.expects(:gid).returns(workspace_gid)
  end

  # @return [void]
  def allow_custom_fields_named
    # @sg-ignore Unresolved call to wrong_custom_field
    wrong_custom_field.expects(:name).returns(wrong_custom_field_name).at_least(0)
    # @sg-ignore Unresolved call to custom_field
    custom_field.expects(:name).returns(custom_field_name).at_least(0)
  end

  # @return [void]
  # @param custom_field_arr [Object]
  def expect_custom_fields_pulled(custom_field_arr)
    expect_workspace_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:custom_fields).returns(custom_fields_api)
    # @sg-ignore Unresolved call to custom_fields_api
    custom_fields_api.expects(:get_custom_fields_for_workspace).returns(custom_field_arr)
    allow_custom_fields_named
  end

  # @return [void]
  def test_custom_field
    custom_fields = get_test_object do
      # @sg-ignore Unresolved call to wrong_custom_field
      # @sg-ignore Unresolved call to custom_field
      custom_field_arr = [wrong_custom_field, custom_field]
      expect_custom_fields_pulled(custom_field_arr)
    end

    # @sg-ignore Unresolved call to custom_field
    # @sg-ignore Unresolved call to custom_field
    assert_equal(custom_field, custom_fields.custom_field(workspace_name, custom_field_name))
  end

  # @return [void]
  def class_under_test
    Checkoff::CustomFields
  end
end
