# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in checkoff.gemspec
gemspec

group :development, :test do
  gem 'bundler'
  gem 'mdl'
  gem 'rspec'
  # ensure recent definitions
  gem 'rbs'
  gem 'sord'
  # ensure version with branch coverage
  gem 'simplecov', ['>=0.18.0']
  gem 'simplecov-lcov'
  gem 'tapioca', require: false
  gem 'undercover'
  gem 'webmock'
end

group :development do
  gem 'brakeman'
  gem 'bump'
  gem 'overcommit', ['>=0.64.0', '<0.65.0']
  gem 'punchlist', ['>=1.3.1']
  gem 'rubocop', ['~> 1.52']
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  # ensure version with RSpec/VerifiedDoubleReference
  gem 'rubocop-rspec', ['>=2.10.0']
  # https://github.com/castwide/solargraph/pull/727
  # gem "solargraph", [">=0.50.0"]
  gem 'solargraph',
      git: 'https://github.com/apiology/solargraph',
      branch: 'master'
  gem 'yard'
end

gem 'pry'
gem 'rake'
