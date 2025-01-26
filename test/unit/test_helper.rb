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
ENV['TZ'] = 'US/Eastern'
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

def let_mock(*mocks)
  mocks.each do |mock_sym|
    let_single_mock(mock_sym)
  end
end

def define_singleton_method_by_proc(obj, name, block)
  metaclass = class << obj; self; end
  metaclass.send(:define_method, name, block)
end

# No security (symbold denial of servie) issue; not building
# OpenStruct from untrusted user data.
#
# rubocop:disable Style/OpenStructUse
class MyOpenStruct < OpenStruct
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
  named_parameters = method.parameters.select { |name, _value| %i[key keyreq].include? name }

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
