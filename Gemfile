# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in checkoff.gemspec
gemspec

gem 'bump'
gem 'bundler'
gem 'fakeweb'
gem 'mdl'
# not a direct dependency - but updates a lot and confuses
# bump+overcommit+bundler when it unexpectedly updates during the
# CircleCI publish step
#
# https://app.circleci.com/pipelines/github/apiology/checkoff/1209/workflows/863fa0ce-097e-4a6b-a49f-f6ed62b29908/jobs/2320
gem 'mime-types', ['=3.5.1']
gem 'minitest-profile'
gem 'minitest-reporters'
gem 'mocha', ['>= 2']
# 0.58.0 and 0.57.0 don't seem super compatible with signatures, and
# magit doesn't seem to want to use the bundled version at the moment,
# so let's favor the more recent version...
gem 'overcommit', ['>=0.60.0', '<0.61.0']
gem 'pry'
gem 'punchlist'
gem 'rake', '~> 13.0'
gem 'rbs'
gem 'rubocop', ['~> 1.52']
gem 'rubocop-minitest'
gem 'rubocop-rake'
# ensure version with branch coverage
gem 'simplecov', ['>=0.18.0']
gem 'simplecov-lcov'
gem 'solargraph', ['>=0.50.0']
gem 'undercover'
gem 'webmock'
gem 'yard'

# ruby-asana gem is pending key bugfixes for checkoff as of
# 2021-07-29:
#
# See
#  https://github.com/Asana/ruby-asana/issues/109
#  https://github.com/Asana/ruby-asana/issues/110
#
gem 'asana',
    git: 'https://github.com/apiology/ruby-asana',
    branch: 'checkoff_fixes'

# gem 'asana', path: '/Users/broz/src/ruby-asana'
