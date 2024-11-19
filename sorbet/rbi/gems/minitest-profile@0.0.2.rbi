# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `minitest-profile` gem.
# Please instead update this file by running `bin/tapioca gem minitest-profile`.


# source://minitest-profile//lib/minitest/profile_plugin.rb#3
module Minitest
  class << self
    # source://minitest/5.21.1/lib/minitest.rb#176
    def __run(reporter, options); end

    # source://minitest/5.21.1/lib/minitest.rb#97
    def after_run(&block); end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def allow_fork; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def allow_fork=(_arg0); end

    # source://minitest/5.21.1/lib/minitest.rb#69
    def autorun; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def backtrace_filter; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def backtrace_filter=(_arg0); end

    # source://minitest/5.21.1/lib/minitest.rb#18
    def cattr_accessor(name); end

    # source://minitest/5.21.1/lib/minitest.rb#1134
    def clock_time; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def extensions; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def extensions=(_arg0); end

    # source://minitest/5.21.1/lib/minitest.rb#271
    def filter_backtrace(bt); end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def info_signal; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def info_signal=(_arg0); end

    # source://minitest/5.21.1/lib/minitest.rb#101
    def init_plugins(options); end

    # source://minitest/5.21.1/lib/minitest.rb#108
    def load_plugins; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def parallel_executor; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def parallel_executor=(_arg0); end

    # source://minitest-profile//lib/minitest/profile_plugin.rb#11
    def plugin_profile_init(options); end

    # source://minitest-profile//lib/minitest/profile_plugin.rb#5
    def plugin_profile_options(opts, options); end

    # source://minitest/5.21.1/lib/minitest.rb#189
    def process_args(args = T.unsafe(nil)); end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def reporter; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def reporter=(_arg0); end

    # source://minitest/5.21.1/lib/minitest.rb#143
    def run(args = T.unsafe(nil)); end

    # source://minitest/5.21.1/lib/minitest.rb#1125
    def run_one_method(klass, method_name); end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def seed; end

    # source://minitest/5.21.1/lib/minitest.rb#19
    def seed=(_arg0); end
  end
end

# source://minitest-profile//lib/minitest/profile_plugin.rb#15
class Minitest::ProfileReporter < ::Minitest::AbstractReporter
  # @return [ProfileReporter] a new instance of ProfileReporter
  #
  # source://minitest-profile//lib/minitest/profile_plugin.rb#20
  def initialize(options); end

  # Returns the value of attribute io.
  #
  # source://minitest-profile//lib/minitest/profile_plugin.rb#18
  def io; end

  # Sets the attribute io
  #
  # @param value the value to set the attribute io to.
  #
  # source://minitest-profile//lib/minitest/profile_plugin.rb#18
  def io=(_arg0); end

  # source://minitest-profile//lib/minitest/profile_plugin.rb#25
  def record(result); end

  # source://minitest-profile//lib/minitest/profile_plugin.rb#29
  def report; end

  # Returns the value of attribute results.
  #
  # source://minitest-profile//lib/minitest/profile_plugin.rb#18
  def results; end

  # Sets the attribute results
  #
  # @param value the value to set the attribute results to.
  #
  # source://minitest-profile//lib/minitest/profile_plugin.rb#18
  def results=(_arg0); end

  # source://minitest-profile//lib/minitest/profile_plugin.rb#43
  def sorted_results; end
end

# source://minitest-profile//lib/minitest/profile_plugin.rb#16
Minitest::ProfileReporter::VERSION = T.let(T.unsafe(nil), String)
