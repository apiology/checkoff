#!/bin/bash -eu

set -o pipefail

underscored_plural_name="${1:?underscored plural name of entities minus .rb}"
class_name="${2:?class name without Checkoff:: prefix}"

cat > "${underscored_plural_name}.rb" << EOF
#!/usr/bin/env ruby

# frozen_string_literal: true

module Checkoff
  module Internal
    class ${class_name}
      def initialize(_deps = {}); end
    end
  end
end
EOF

git add "${underscored_plural_name}.rb"
