# frozen_string_literal: true
# typed: strict

#
# https://gist.github.com/castwide/28b349566a223dfb439a337aea29713e
#
# The following comments fill some of the gaps in Solargraph's
# understanding of types. Since they're all in YARD, they get mapped
# in Solargraph but ignored at runtime.
#
# You can put this file anywhere in the project, as long as it gets included in
# the workspace maps. It's recommended that you keep it in a standalone file
# instead of pasting it into an existing one.
#
# @!override Hash<[String,Symbol],String>#fetch
#   @return [String>]
#
# @!parse
#   module Bundler
#     class << self
#       # @param groups [Array<Symbol>]
#       #
#       # @return [void]
#       def require(*groups); end
#     end
#   end
#   module OpenSSL
#     module SSL
#       # @type [Integer]
#       VERIFY_PEER = 1
#       # @type [Integer]
#       VERIFY_NONE = 0
#     end
#   end
#   class Time
#     class << self
#       # @param time [String]
#       # @param now [nil,Time]
#       # @return [Time]
#       def parse(time, now=nil); end
#     end
#     # https://ruby-doc.org/3.2.2/exts/date/Time.html#method-i-to_date#
#     # @return [Date]
#     def to_date; end
#   end
#   class Date
#     class << self
#       # @param date [String]
#       # @param comp [Boolean]
#       # @param state [Object]
#       # @return [Date]
#       def parse(date='-4712-01-01', comp=true, state=Date::ITALY); end
#       # @param start [Integer]
#       # @return [Date]
#       def today(start=Date::ITALY); end
#     end
#   end
#   module IRB
#     class << self
#       # @return [void]
#       def start; end
#     end
#   end
#   # Test files use `extend Forwardable; def_delegators(:@mocks, :a, :b, ...)`
#   # to expose @mocks entries as bare methods. Forwardable defines these
#   # dynamically, so give Solargraph a macro to synthesize the pins.
#   module Forwardable
#     # @!macro [new] def_delegators
#     #   @!method $2
#     #     @return [Mocha::Mock]
#     #   @!method $3
#     #     @return [Mocha::Mock]
#     #   @!method $4
#     #     @return [Mocha::Mock]
#     #   @!method $5
#     #     @return [Mocha::Mock]
#     #   @!method $6
#     #     @return [Mocha::Mock]
#     #   @!method $7
#     #     @return [Mocha::Mock]
#     #   @!method $8
#     #     @return [Mocha::Mock]
#     #   @!method $9
#     #     @return [Mocha::Mock]
#     #   @!method $10
#     #     @return [Mocha::Mock]
#     #   @!method $11
#     #     @return [Mocha::Mock]
#     # @param accessor [Symbol]
#     # @param methods [Symbol]
#     # @return [void]
#     def def_delegators(accessor, *methods); end
#   end
#   module Mocha
#     class Expectation
#       # @param value [Object]
#       # @return [Mocha::Expectation]
#       def returns(value = nil); end
#       # @param args [Object]
#       # @return [Mocha::Expectation]
#       def with(*args); end
#       # @return [Mocha::Expectation]
#       def yields(*args); end
#       # @param count [Integer]
#       # @return [Mocha::Expectation]
#       def at_least(count); end
#       # @return [Mocha::Expectation]
#       def at_least_once; end
#       # @param count [Integer]
#       # @return [Mocha::Expectation]
#       def times(count); end
#     end
#     class Mock
#       # @param method_name [Symbol, String]
#       # @return [Mocha::Expectation]
#       def expects(method_name); end
#       # @param method_name [Symbol, String]
#       # @return [Mocha::Expectation]
#       def stubs(method_name); end
#       # @param type [Class]
#       # @return [void]
#       def responds_like_instance_of(type); end
#       # @param type [Class, Module]
#       # @return [void]
#       def responds_like(type); end
#     end
#   end
#   class Object
#     # @param method_name [Symbol, String]
#     # @return [Mocha::Expectation]
#     def expects(method_name); end
#     # @param method_name [Symbol, String]
#     # @return [Mocha::Expectation]
#     def stubs(method_name); end
#     # @param name [String]
#     # @return [Mocha::Mock]
#     def mock(name = nil); end
#     # @!macro [new] let_single_mock
#     #   @!method $1
#     #     @return [Mocha::Mock]
#     # @param mock_sym [Symbol]
#     # @return [void]
#     def let_single_mock(mock_sym); end
#     # @!macro [new] typed_mock
#     #   @!method $1
#     #     @return [Mocha::Mock & $2]
#     # @param mock_sym [Symbol]
#     # @param type [Class]
#     # @return [void]
#     def typed_mock(mock_sym, type); end
#     # @!macro [new] typed_let_mock
#     #   @!method $1
#     #     @return [Mocha::Mock & $2]
#     # @param mock_sym [Symbol]
#     # @param type [Class]
#     # @return [void]
#     def typed_let_mock(mock_sym, type); end
#     # @!macro [new] typed_delegate
#     #   @!method $1
#     #     @return [Mocha::Mock & $2]
#     # @param mock_sym [Symbol]
#     # @param type [Class]
#     # @return [void]
#     def typed_delegate(mock_sym, type); end
#     # @param clazz [Class]
#     # @param respond_like_instance_of [Hash, nil]
#     # @param respond_like [Hash, nil]
#     # @param skip_these_keys [Array<Symbol>]
#     # @return [MyOpenStruct]
#     def get_initializer_mocks(clazz, respond_like_instance_of:, respond_like:, skip_these_keys: []); end
#     # @param mock_syms [Array<Symbol>]
#     # @return [Hash{Symbol => Mocha::Mock}]
#     def create_hash_of_mocks(mock_syms); end
#   end
#   # Test helper DSLs (defined in test/unit/test_helper.rb; that file stays
#   # excluded from strong typecheck because of Mocha-heavy internals).
#   class MyOpenStruct < OpenStruct
#     # @param sym [Symbol]
#     # @return [void]
#     def delete(sym); end
#     # @param hash [Hash]
#     # @return [self]
#     def merge!(hash); end
#   end
