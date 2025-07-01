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
  gem 'parlour',
      github: 'apiology/parlour',
      branch: 'fix_io_deadlock'
  gem 'rbi'
  # ensure recent definitions
  gem 'rbs', ['>=3.8.1']
  gem 'rspec'
  gem 'sord', # ['>= 6.0.0'] # ,
      # github: 'apiology/sord',
      # branch: 'type_variable_support'
      path: '../sord'
  # ensure version with branch coverage
  gem 'simplecov', ['>=0.18.0']
  gem 'simplecov-lcov'
  gem 'tapioca', ['>= 0.16.0'], require: false
  # need --exclude-files
  gem 'undercover', ['>=0.6.3']
  gem 'webmock'
end

group :development do
  gem 'brakeman'
  gem 'bump'
  gem 'bundler-audit'
  gem 'fasterer'
  gem 'overcommit', # [">=0.64.0", "<0.65.0"]
      git: 'https://github.com/apiology/overcommit.git',
      branch: 'add_solargraph'
  gem 'punchlist', ['>=1.3.1']
  gem 'rubocop', ['~> 1.52']
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  # ensure version with RSpec/VerifiedDoubleReference
  gem 'rubocop-rspec', ['>=3.4.0']
  gem 'solargraph', ['>=0.51.2']
  gem 'yard',
      git: 'https://github.com/apiology/yard',
      branch: 'fix_word_array_in_array_parsing'
  gem 'yard-sorbet'
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
