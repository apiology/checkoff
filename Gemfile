# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in checkoff.gemspec
gemspec

group :development, :test do
  gem 'bundler'
  gem 'mdl'
  gem 'parlour',
      github: 'apiology/parlour',
      branch: 'fix_io_deadlock'
  gem 'rbi'
  # ensure recent definitions
  gem 'rbs', ['>=3.8.1']
  gem 'rspec'
  gem 'sord', # ['>= 6.0.0'] # ,
      github: 'apiology/sord',
      branch: '2025-07-04'
  #   path: '../sord'
  # ensure version with branch coverage
  gem 'simplecov', ['>=0.18.0']
  gem 'simplecov_json_formatter'
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
  gem 'overcommit', '~>0.68.0'
  gem 'punchlist', ['>=1.3.1']
  gem 'rubocop', ['~> 1.52']
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-yard'
  # ensure version with RSpec/VerifiedDoubleReference
  gem 'rubocop-rspec', ['>=3.4.0']
  gem 'solargraph', ['>=0.56']
  # need https://github.com/lsegal/yard/pull/1604
  gem 'yard',
      github: 'lsegal/yard',
      branch: 'main'
  gem 'yard-sorbet'
end

gem 'rake'
