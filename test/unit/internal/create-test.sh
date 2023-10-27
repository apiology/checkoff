#!/bin/bash -eu

set -o pipefail

underscored_name="${1:?underscored name minus .rb or test_}"
class_name="${2:?class name}"

cat > test_"${underscored_name}.rb" << EOF
# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../class_test'
require 'checkoff/internal/${underscored_name}'

class Test${class_name} < ClassTest
  def test_foo
    ${underscored_name} = get_test_object
    assert_equal(123, ${underscored_name}.foo)
  end

  def class_under_test
    Checkoff::Internal::${class_name}
  end

  def respond_like_instance_of
    {
    }
  end

  def respond_like
    {
    }
  end
end
EOF

git add "test_${underscored_name}.rb"

echo "Created test_${underscored_name}.rb"
