# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in checkoff.gemspec
gemspec

group :development, :test do
  gem 'bundler'
  gem 'mdl'
  gem 'minitest'
  gem 'minitest-profile'
  gem 'minitest-reporters'
  gem 'mocha', ['>= 2']
  # ensure recent definitions
  gem 'rbs'
  # ensure version with branch coverage
  gem 'simplecov', ['>=0.18.0']
  gem 'simplecov-lcov'
  gem 'undercover'
  gem 'webmock'
end

group :development do
  gem 'brakeman'
  gem 'bump'
  gem 'overcommit', ['>=0.64.1', '<0.65.0']
  gem 'punchlist', ['>=1.3.1']
  gem 'rubocop', ['~> 1.52']
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  # ensure version with RSpec/VerifiedDoubleReference
  gem 'rubocop-rspec', ['>=2.10.0']
  # https://github.com/castwide/solargraph/pull/727
  # gem "solargraph", [">=0.50.0"]
  gem 'solargraph',
      git: 'https://github.com/apiology/solargraph',
      branch: 'master'
  gem 'solargraph-rails',
      git: 'https://github.com/apiology/solargraph-rails',
      branch: 'main'
  gem 'yard'
end

# not a direct dependency - but updates a lot and confuses
# bump+overcommit+bundler when it unexpectedly updates during the
# CircleCI publish step
#
# https://app.circleci.com/pipelines/github/apiology/checkoff/1209/workflows/863fa0ce-097e-4a6b-a49f-f6ed62b29908/jobs/2320
gem 'mime-types', ['=3.5.1']
gem 'pry'
gem 'rake'
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
