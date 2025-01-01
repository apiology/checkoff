# coding: ascii
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkoff/version'

Gem::Specification.new do |spec|
  spec.name          = 'checkoff'
  spec.version       = Checkoff::VERSION
  spec.authors       = ['Vince Broz']
  spec.email         = ['vince@broz.cc']
  spec.summary       = 'Command-line and gem client for Asana (unofficial)'
  spec.homepage      = 'https://github.com/apiology/checkoff'
  spec.license       = 'MIT license'
  spec.required_ruby_version = '>= 3.0'

  spec.files         = Dir['README.md',
                           'Rakefile',
                           'lib/checkoff.rb',
                           '{lib}/**/*',
                           'sig/**/*.rbs',
                           'sig/*.rbs',
                           'rbi/**/*.rbi',
                           'rbi/*.rbi',
                           '{exe}/*',
                           'checkoff.gemspec']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # spec.add_dependency 'activesupport'

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
  }
end
