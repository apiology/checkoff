# coding: ascii
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkoff/version'

Gem::Specification.new do |spec|
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to name= -- rbs's bundled core/rubygems/specification.rbs
  #   declares Gem::Specification (and its Gem::BasicSpecification superclass)
  #   with zero method signatures, so every call on the Gem::Specification.new
  #   block param is unresolved.
  spec.name = 'checkoff'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to version= -- see name= above.
  spec.version = Checkoff::VERSION
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to authors= -- see name= above.
  spec.authors = ['Vince Broz']
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to email= -- see name= above.
  spec.email = ['vince@broz.cc']
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to summary= -- see name= above.
  spec.summary = 'Command-line and gem client for Asana (unofficial)'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to homepage= -- see name= above.
  spec.homepage = 'https://github.com/apiology/checkoff'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to license= -- see name= above.
  spec.license = 'MIT license'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to required_ruby_version= -- see name= above.
  spec.required_ruby_version = '>= 3.3'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to files= -- see name= above.
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
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to bindir= -- see name= above.
  spec.bindir = 'exe'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to executables= -- see name= above.
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to require_paths= -- see name= above.
  spec.require_paths = ['lib']
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to add_dependency -- see name= above.
  spec.add_dependency 'activesupport'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to add_dependency -- see name= above.
  spec.add_dependency 'asana', '>0.10.0'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to add_dependency -- see name= above.
  spec.add_dependency 'cache_method'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to add_dependency -- see name= above.
  spec.add_dependency 'gli'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to add_dependency -- see name= above.
  spec.add_dependency 'mime-types'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to add_dependency -- see name= above.
  spec.add_dependency 'sorbet-runtime'
  # @sg-ignore upstream-type-annotation:rubygems-specification-rbs-gap
  #   Unresolved call to metadata= -- see name= above.
  spec.metadata = {
    'rubygems_mfa_required' => 'false',
  }
end
