# frozen_string_literal: true
# coding: ascii
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkoff/version'

Gem::Specification.new do |spec|
  spec.name          = 'checkoff'
  spec.version       = Checkoff::VERSION
  spec.authors       = ['Vince Broz']
  spec.email         = ['vince@broz.cc']

  spec.summary       = 'Command-line and gem client for Asana (unofficial)'
  spec.homepage      = 'http://github.com/apiology/checkoff'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dalli'
  spec.add_runtime_dependency 'cache_method'
  spec.add_runtime_dependency 'asana'
  spec.add_runtime_dependency 'active_support'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>=3.4'
  spec.add_development_dependency 'quality'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'minitest-profile'
  spec.add_development_dependency 'mocha'
end
