# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in checkoff.gemspec
gemspec

gem 'bump'
gem 'bundler'

gem 'brakeman'
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
gem 'ostruct'
gem 'overcommit', ['>=0.64.0', '<0.65.0']
gem 'pry'
gem 'punchlist', ['>=1.3.1']
gem 'rake'
gem 'rbs'
gem 'rubocop', ['~> 1.52']
gem 'rubocop-minitest'
gem 'rubocop-performance'
gem 'rubocop-rake'
# ensure version with branch coverage
gem 'simplecov', ['>=0.18.0']
gem 'simplecov-lcov'
gem 'solargraph',
    git: 'https://github.com/apiology/solargraph',
    branch: 'master'
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
