# coding: ascii
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
# @sg-ignore $LOAD_PATH is a special Object in RBS
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkoff/version'

Gem::Specification.new do |spec|
  # @sg-ignore
  spec.name = 'checkoff'
  # @sg-ignore
  spec.version = Checkoff::VERSION
  # @sg-ignore
  spec.authors = ['Vince Broz']
  # @sg-ignore
  spec.email = ['vince@broz.cc']
  # @sg-ignore
  spec.summary = 'Command-line and gem client for Asana (unofficial)'
  # @sg-ignore
  spec.homepage = 'https://github.com/apiology/checkoff'
  # @sg-ignore
  spec.license = 'MIT license'
  # @sg-ignore
  spec.required_ruby_version = '>= 3.3'
  # @sg-ignore
  spec.files = Dir['README.md',
                   'Rakefile',
                   'lib/checkoff.rb',
                   '{lib}/**/*',
                   'sig/**/*.rbs',
                   'sig/*.rbs',
                   'rbi/**/*.rbi',
                   'rbi/*.rbi',
                   '{exe}/*',
                   'checkoff.gemspec']
  # @sg-ignore
  spec.bindir = 'exe'
  # @sg-ignore
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # @sg-ignore
  spec.require_paths = ['lib']
  # @sg-ignore
  spec.add_dependency 'activesupport'
  # @sg-ignore
  spec.add_dependency 'asana', '>0.10.0'
  # @sg-ignore
  spec.add_dependency 'cache_method'
  # @sg-ignore
  spec.add_dependency 'gli'
  # @sg-ignore
  spec.add_dependency 'mime-types'
  # @sg-ignore
  spec.add_dependency 'sorbet-runtime'
  # @sg-ignore
  spec.metadata = {
    'rubygems_mfa_required' => 'false',
  }
end
