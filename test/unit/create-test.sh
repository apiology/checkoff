#!/bin/bash -eu

set -o pipefail

underscored_plural_name="${1:?underscored name minus .rb or test_}"
# Sorry, shellcheck, I can't express 'end of line' in a simple variable search and replace
# shellcheck disable=SC2001
underscored_singular_name=$(sed -e 's/s$//g' <<< "${underscored_plural_name}")
class_name="${2:?class name}"

cat > test_"${underscored_plural_name}.rb" << EOF
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/${underscored_plural_name}'

class Test${class_name} < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client)

  let_mock :workspace_name, :${underscored_singular_name}_name, :${underscored_singular_name}, :workspace, :workspace_gid,
           :${underscored_plural_name}_api, :wrong_${underscored_singular_name}, :wrong_${underscored_singular_name}_name

  def test_${underscored_singular_name}_or_raise_raises
    ${underscored_plural_name} = get_test_object do
      ${underscored_singular_name}_arr = [wrong_${underscored_singular_name}]
      expect_${underscored_plural_name}_pulled(${underscored_singular_name}_arr)
    end
    assert_raises(RuntimeError) do
      ${underscored_plural_name}.${underscored_singular_name}_or_raise(workspace_name, ${underscored_singular_name}_name)
    end
  end

  def test_${underscored_singular_name}_or_raise
    ${underscored_plural_name} = get_test_object do
      ${underscored_singular_name}_arr = [wrong_${underscored_singular_name}, ${underscored_singular_name}]
      expect_${underscored_plural_name}_pulled(${underscored_singular_name}_arr)
    end
    assert_equal(${underscored_singular_name}, ${underscored_plural_name}.${underscored_singular_name}_or_raise(workspace_name, ${underscored_singular_name}_name))
  end

  def expect_workspace_pulled
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
    workspace.expects(:gid).returns(workspace_gid)
  end

  def allow_${underscored_plural_name}_named
    wrong_${underscored_singular_name}.expects(:name).returns(wrong_${underscored_singular_name}_name).at_least(0)
    ${underscored_singular_name}.expects(:name).returns(${underscored_singular_name}_name).at_least(0)
  end

  def expect_${underscored_plural_name}_pulled(${underscored_singular_name}_arr)
    expect_workspace_pulled
    client.expects(:${underscored_plural_name}).returns(${underscored_plural_name}_api)
    ${underscored_plural_name}_api.expects(:get_${underscored_plural_name}_for_workspace).returns(${underscored_singular_name}_arr)
    allow_${underscored_plural_name}_named
  end

  def test_${underscored_singular_name}
    ${underscored_plural_name} = get_test_object do
      ${underscored_singular_name}_arr = [wrong_${underscored_singular_name}, ${underscored_singular_name}]
      expect_${underscored_plural_name}_pulled(${underscored_singular_name}_arr)
    end
    assert_equal(${underscored_singular_name}, ${underscored_plural_name}.${underscored_singular_name}(workspace_name, ${underscored_singular_name}_name))
  end

  def class_under_test
    Checkoff::${class_name}
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {
    }
  end
end
EOF

git add "test_${underscored_plural_name}.rb"

echo "Created test_${underscored_plural_name}.rb"
