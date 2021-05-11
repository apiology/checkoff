# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  # this dir used by TravisCI/CircleCI
  add_filter '/vendor/bundle'
  enable_coverage(:branch) # Report branch coverage to trigger branch-level undercover warnings
end
SimpleCov.refuse_coverage_drop

require 'minitest/autorun'
require 'mocha/minitest'
require 'minitest/profile'
require 'ostruct'

require_relative 'cachemethoddouble'
require_relative '../../lib/checkoff'
require_relative 'test_date'

ENV['TZ'] = 'US/Eastern'

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

def get_initializer_mocks(clazz, skip_these_keys: [])
  parameters = clazz.instance_method(:initialize).parameters
  named_parameters = parameters.select do |name, _value|
    name == :key
  end
  mock_syms = named_parameters.map { |_name, value| value } - skip_these_keys

  # create a hash of argument name to a new mock
  OpenStruct.new Hash[*mock_syms.map { |sym| [sym, mock(sym.to_s)] }.flatten]
end
