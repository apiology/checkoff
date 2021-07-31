#!/bin/bash -eu

set -o pipefail

underscored_name="${1:?underscored name minus .rb or test_}"
class_name="${2:?class name}"

cat > test_"${underscored_name}.rb" << EOF
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'

class Test${class_name} < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :sources)

  let_mock :stocks

  def test_init
    ${underscored_name} = get_test_object
    refute ${underscored_name}.nil?
  end

  def class_under_test
    Checkoff::${class_name}
  end
end
EOF

git add "test_${underscored_name}.rb"

echo "Created test_${underscored_name}.rb"
