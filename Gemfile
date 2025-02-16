# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in checkoff.gemspec
gemspec

group :development, :test do
  gem 'bundler'
  gem 'mdl'
  gem 'parlour',
      git: 'https://github.com/apiology/parlour',
      branch: 'heredoc_constant_handling'
  gem 'rbi',
      git: 'https://github.com/apiology/rbi',
      branch: 'basic_heredoc_support'
  # ensure recent definitions
  gem 'rbs', ['>=3.8.1']
  gem 'rspec'
  gem 'sord',
      git: 'https://github.com/apiology/sord',
      branch: 'generate_heredocs_in_constants'
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
  gem 'overcommit', ['>=0.64.0', '<0.65.0']
  gem 'punchlist', ['>=1.3.1']
  gem 'rubocop', ['~> 1.52']
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

gem 'pry'
gem 'rake'
