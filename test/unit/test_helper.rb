# typed: false
# frozen_string_literal: true

# neither ruby-asana nor gli gems are $VERBOSE-clean
$VERBOSE = false
require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter,
  ]
)
SimpleCov.start do
  # this dir used by TravisCI/CircleCI
  add_filter '/vendor/bundle'
  enable_coverage(:branch) # Report branch coverage to trigger branch-level undercover warnings
end
require 'webmock/minitest'
WebMock.disable_net_connect!
require 'minitest/autorun'
require 'mocha/minitest'

Mocha.configure do |c|
  # Detect Ruby 2 -> 3 kwarg issues
  c.strict_keyword_argument_matching = true
end

require 'minitest/profile'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(location: true)]

require 'ostruct'
require_relative 'cachemethoddouble'
ENV['LOG_LEVEL'] = 'WARN'
ENV['TZ'] = 'America/New_York'
require_relative '../../lib/checkoff'

def let_single_mock(mock_sym)
  define_method(mock_sym.to_s) do
    var = "@#{mock_sym}"
    mock = instance_variable_get(var)
    unless mock
      mock = mock(mock_sym.to_s)
      instance_variable_set var, mock
    end
    mock
  end
end

# @param mock_sym [Symbol]
# @param type [Class]
#
# @return [void]
def typed_mock(mock_sym, type)
  define_method(mock_sym.to_s) do
    var = "@#{mock_sym}"
    mock = instance_variable_get(var)
    unless mock
      mock = mock(mock_sym.to_s)
      instance_variable_set var, mock
      mock.responds_like_instance_of(type)
    end
    mock
  end
end

# Like typed_mock, but skips responds_like_instance_of at runtime.
# ruby-asana's Asana::Resources::Resource#respond_to_missing? assumes an
# initialized @attributes hash; responds_like_instance_of allocates the
# responder class via Class#allocate (bypassing #initialize), so any
# unstubbed method call on the mock crashes with NoMethodError inside
# ruby-asana itself rather than Mocha's own error. Only the static type
# (Mocha::Mock & type, via the matching Solargraph macro) is wanted here.
#
# @param mock_sym [Symbol]
# @param type [Class]
#
# @return [void]
def typed_let_mock(mock_sym, type)
  let_single_mock(mock_sym)
end

def let_mock(*mocks)
  mocks.each do |mock_sym|
    let_single_mock(mock_sym)
  end
end

def define_singleton_method_by_proc(obj, name, block)
  metaclass = class << obj; self; end
  metaclass.send(:define_method, name, block)
end

module Asana
  # Real (but empty) backing classes for the per-resource collection types
  # documented in config/annotations_asana.rb's @!parse block (e.g.
  # Asana::Client#tasks is annotated to return Asana::ProxiedResourceClasses::Task).
  # That block is YARD-comment-only, so it never defines these constants at
  # runtime; typed_let_mock needs a real, loadable class to pass as its
  # `type` argument, so it's defined here and picked up by the @!parse
  # method annotations for static typing.
  # rubocop:disable Lint/EmptyClass
  module ProxiedResourceClasses
    class Task; end
    class Workspace; end
    class Project; end
    class Section; end
  end
  # rubocop:enable Lint/EmptyClass
end

# No security (symbold denial of servie) issue; not building
# OpenStruct from untrusted user data.
#
# rubocop:disable Style/OpenStructUse
class MyOpenStruct < OpenStruct
  # @return [void]
  def delete(sym)
    delete_field(sym) if respond_to? sym
  end

  def merge!(hash)
    hash.each do |k, v|
      self[k] = v
    end
  end
end
# rubocop:enable Style/OpenStructUse

def ensure_respond_like(mocks, respond_like_instance_of, respond_like)
  mocks.to_h.each do |mock_name, mock|
    if respond_like_instance_of.include?(mock_name)
      mock.responds_like_instance_of(respond_like_instance_of.fetch(mock_name.to_sym))
    elsif respond_like.include?(mock_name)
      mock.responds_like(respond_like.fetch(mock_name.to_sym))
    else
      raise "Please specify type of #{mock_name} in your 'respond_like_instance_of' or 'respond_like' methods"
    end
  end
end

def create_hash_of_mocks(mock_syms)
  Hash[*mock_syms.map { |sym| [sym, mock(sym.to_s)] }.flatten]
end

def get_initializer_mocks(clazz,
                          respond_like_instance_of:,
                          respond_like:,
                          skip_these_keys: [])
  method = clazz.instance_method(:initialize)

  # rubocop:disable Style/HashSlice
  named_parameters = method.parameters.select { |name, _value| %i[key keyreq].include? name }
  # rubocop:enable Style/HashSlice

  mock_syms = named_parameters.map { |_name, value| value } - skip_these_keys

  # create a hash of argument name to a new mock
  mocks = MyOpenStruct.new create_hash_of_mocks(mock_syms)
  unless respond_like_instance_of.nil? && respond_like.nil?
    ensure_respond_like(mocks, respond_like_instance_of, respond_like)
  end
  mocks
end

module Mocha
  class Mock
    def is_a?(expected)
      @responder.class <= expected || super
    end
  end
end
