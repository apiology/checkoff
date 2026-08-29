# coding: ascii
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
# @sg-ignore likely-stale
#   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
#   Original reason: $LOAD_PATH is a special Object in RBS.
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkoff/version'

Gem::Specification.new do |spec|
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.name = 'checkoff'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.version = Checkoff::VERSION
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.authors = ['Vince Broz']
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.email = ['vince@broz.cc']
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.summary = 'Command-line and gem client for Asana (unofficial)'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.homepage = 'https://github.com/apiology/checkoff'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.license = 'MIT license'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.required_ruby_version = '>= 3.3'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
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
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.bindir = 'exe'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.require_paths = ['lib']
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.add_dependency 'activesupport'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.add_dependency 'asana', '>0.10.0'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.add_dependency 'cache_method'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.add_dependency 'gli'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.add_dependency 'mime-types'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.add_dependency 'sorbet-runtime'
  # @sg-ignore likely-stale
  #   checkoff.gemspec is excluded from typecheck via '*.gemspec' in .solargraph.yml; suppression is inert.
  spec.metadata = {
    'rubygems_mfa_required' => 'false',
  }
end
