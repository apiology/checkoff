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

# responds_like_instance_of builds its responder via Class#allocate, which
# MRI refuses for these classes (no heap representation to carve out --
# their values are immediates or interned). responds_like takes a real
# instance instead, so a literal value works directly.
NON_ALLOCATABLE_EXAMPLES = {
  Symbol => :placeholder,
  Integer => 0,
  Float => 0.0,
  NilClass => nil,
  TrueClass => true,
  FalseClass => false,
}.freeze

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
      if NON_ALLOCATABLE_EXAMPLES.key?(type)
        mock.responds_like(NON_ALLOCATABLE_EXAMPLES.fetch(type))
      else
        mock.responds_like_instance_of(type)
      end
    end
    mock
  end
end

# Exposes an existing @mocks entry (from get_initializer_mocks) as a
# precisely-typed bare method, like def_delegators but with a real
# type instead of the generic Mocha::Mock the def_delegators macro
# provides.
#
# @param mock_sym [Symbol]
# @param type [Class]
#
# @return [void]
def typed_delegate(mock_sym, type)
  define_method(mock_sym.to_s) do
    mocks.public_send(mock_sym)
  end
end

def define_singleton_method_by_proc(obj, name, block)
  metaclass = class << obj; self; end
  metaclass.send(:define_method, name, block)
end

module Asana
  # Real backing classes for the per-resource collection types documented in
  # config/annotations_asana.rb's @!parse block (e.g. Asana::Client#tasks is
  # annotated to return Asana::ProxiedResourceClasses::Task). That block is
  # YARD-comment-only, so it never defines these constants at runtime;
  # typed_mock needs a real, loadable class to pass as its `type` argument,
  # so it's defined here and picked up by the @!parse method annotations for
  # static typing.
  #
  # Each class stubs out the specific methods checkoff actually calls on the
  # real ruby-asana collection proxy, with matching arity, so that
  # responds_like_instance_of can verify both that the method exists and
  # that it's being called with a compatible signature.
  module ProxiedResourceClasses
    class Tag
      # @return [Array<Asana::Resources::Tag>]
      def get_tags_for_workspace(workspace_gid:); end
    end

    class Task
      # @return [Enumerable<Asana::Resources::Task>]
      def find_all(**options); end

      # @return [Asana::Resources::Task]
      def find_by_id(task_gid, options: {}); end

      # @return [Enumerable<Asana::Resources::Task>]
      def get_tasks(section:, **options); end

      # @return [Array<Asana::Resources::Task>]
      def to_a; end
    end

    class Workspace
      # @return [Enumerable<Asana::Resources::Workspace>]
      def find_all; end
    end

    class Section
      # @return [Enumerable<Asana::Resources::Section>]
      def get_sections_for_project(project_gid:, **options); end
    end

    class Project
      # @return [Asana::Resources::Project]
      def find_by_id(gid, options: {}); end

      # @return [Enumerable<Asana::Resources::Project>]
      def find_by_workspace(workspace:, **options); end
    end

    class UserTaskList
      # @return [Asana::Resources::UserTaskList]
      def get_user_task_list_for_user(user_gid:, **options); end
    end

    class Portfolio
      # @return [Asana::Resources::Portfolio]
      def find_by_id(portfolio_gid, options: {}); end

      # @return [Enumerable<Asana::Resources::Portfolio>]
      def find_all(**options); end

      # @return [Enumerable<Asana::Resources::Project>]
      def get_items_for_portfolio(portfolio_gid:, **options); end
    end

    class User
      # @return [Asana::Resources::User]
      def me; end
    end

    class CustomField
      # @return [Array<Asana::Resources::CustomField>]
      def get_custom_fields_for_workspace(workspace_gid:); end
    end
  end
end

# The live Asana API has fields this pinned ruby-asana gem hasn't caught
# up on declaring as attr_readers. Curated here (like
# Asana::ProxiedResourceClasses above) so the strict duck-type check below
# doesn't reject legitimate calls to them.
module Asana
  module Resources
    class Task
      attr_reader :assignee_section, :start_at
    end

    # #name is declared separately on every concrete subclass (Task,
    # Project, Tag, Section, Portfolio, Workspace, User -- everything
    # except CustomField) rather than hoisted onto the shared base class
    # upstream. Checkoff code that handles a resource of unknown/mixed
    # type (e.g. Checkoff::Resources#resource_by_gid) is typed as the
    # base Resource and still calls #name, relying on that duck type.
    class Resource
      attr_reader :name
    end
  end
end

# typed_mock's responds_like_instance_of allocates a responder via
# Class#allocate, bypassing #initialize, so Asana::Resources::Resource
# subclasses (Task, Project, etc.) end up with a nil @_data. Statically
# declared attrs (attr_reader :gid etc., including the curated ones just
# above) are real methods and unaffected, but any method proxied through
# respond_to_missing? -> to_h.key?(...) crashes with NoMethodError on the
# nil @_data instead of returning false/true. Return false: an
# undeclared/uncurated attribute call on a no-data responder is either a
# typo or a real field this file hasn't caught up on yet -- both should
# fail loudly rather than be silently accepted. Prepending (not
# reopening -- reopening would replace the original method entirely and
# break `super`) is what lets this still fall through to the real
# to_h.key?(...) check once @_data is populated (a genuine Resource
# built from real data).
module Asana
  module Resources
    module SafeRespondToMissingOnUninitializedResource
      def respond_to_missing?(name, include_private = false)
        return false if @_data.nil?

        super
      end

      def to_s
        return "#<#{self.class} (no data)>" if @_data.nil?

        super
      end
      alias inspect to_s
    end

    class Resource
      prepend SafeRespondToMissingOnUninitializedResource
    end
  end
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
