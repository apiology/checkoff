#!/bin/bash -eu

set -o pipefail

underscored_name="${1:?underscored name minus .rb or test_}"
class_name="${2:?class name minus Source}"

relative_path='../../..'
if [ "${PWD##*/test/unit}" = "/sources" ]
then
  relative_path='..'
fi


cat > test_"${underscored_name}.rb" << EOF
# frozen_string_literal: true

require_relative '${relative_path}/test_helper'
require_relative '${relative_path}/class_test'
require_relative '${relative_path}/base_source_test'

class Test${class_name} < BaseSourceTest
  extend Forwardable

  def_delegators(:@mocks, :sources)

  let_mock :stocks

  def test_init
    ${underscored_name} = get_test_object
    refute ${underscored_name}.nil?
  end

  def class_under_test
    ${class_name}Source
  end
end
EOF

git add "test_${underscored_name}.rb"

echo "Created test_${underscored_name}.rb"
