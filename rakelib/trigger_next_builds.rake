# frozen_string_literal: true

desc 'Generate plate-spinner build'
task :trigger_next_builds do
  sh 'set -x; curl -v -X POST https://circleci.com/api/v1/project/apiology/' \
     'plate-spinner/tree/main?circle-token=$CIRCLE_TOKEN'
end
