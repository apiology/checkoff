# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `mixlib-cli` gem.
# Please instead update this file by running `bin/tapioca gem mixlib-cli`.


# source://mixlib-cli//lib/mixlib/cli/formatter.rb#2
module Mixlib; end

# == Mixlib::CLI
# Adds a DSL for defining command line options and methods for parsing those
# options to the including class.
#
# Mixlib::CLI does some setup in #initialize, so the including class must
# call `super()` if it defines a custom initializer.
#
# === DSL
# When included, Mixlib::CLI also extends the including class with its
# ClassMethods, which define the DSL. The primary methods of the DSL are
# ClassMethods#option, which defines a command line option;
# ClassMethods#banner, which defines the "usage" banner;
# and ClassMethods#deprecated_option, which defines a deprecated command-line option.
#
# === Parsing
# Command line options are parsed by calling the instance method
# #parse_options. After calling this method, the attribute #config will
# contain a hash of `:option_name => value` pairs.
#
# source://mixlib-cli//lib/mixlib/cli/formatter.rb#3
module Mixlib::CLI
  mixes_in_class_methods ::Mixlib::CLI::ClassMethods
  mixes_in_class_methods ::Mixlib::CLI::InheritMethods

  # Create a new Mixlib::CLI class.  If you override this, make sure you call super!
  #
  # === Parameters
  # *args<Array>:: The array of arguments passed to the initializer
  #
  # === Returns
  # object<Mixlib::Config>:: Returns an instance of whatever you wanted :)
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#260
  def initialize(*args); end

  # Banner for the option parser. If the option parser is printed, e.g., by
  # `puts opt_parser`, this string will be used as the first line.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#251
  def banner; end

  # Banner for the option parser. If the option parser is printed, e.g., by
  # `puts opt_parser`, this string will be used as the first line.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#251
  def banner=(_arg0); end

  # source://mixlib-cli//lib/mixlib/cli.rb#432
  def build_option_arguments(opt_setting); end

  # Any arguments which were not parsed and placed in "config"--the leftovers.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#247
  def cli_arguments; end

  # Any arguments which were not parsed and placed in "config"--the leftovers.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#247
  def cli_arguments=(_arg0); end

  # A Hash containing the values supplied by command line options.
  #
  # The behavior and contents of this Hash vary depending on whether
  # ClassMethods#use_separate_default_options is enabled.
  # ==== use_separate_default_options *disabled*
  # After initialization, +config+ will contain any default values defined
  # via the mixlib-config DSL. When #parse_options is called, user-supplied
  # values (from ARGV) will be merged in.
  # ==== use_separate_default_options *enabled*
  # After initialization, this will be an empty hash. When #parse_options is
  # called, +config+ is populated *only* with user-supplied values.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#236
  def config; end

  # A Hash containing the values supplied by command line options.
  #
  # The behavior and contents of this Hash vary depending on whether
  # ClassMethods#use_separate_default_options is enabled.
  # ==== use_separate_default_options *disabled*
  # After initialization, +config+ will contain any default values defined
  # via the mixlib-config DSL. When #parse_options is called, user-supplied
  # values (from ARGV) will be merged in.
  # ==== use_separate_default_options *enabled*
  # After initialization, this will be an empty hash. When #parse_options is
  # called, +config+ is populated *only* with user-supplied values.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#236
  def config=(_arg0); end

  # If ClassMethods#use_separate_default_options is enabled, this will be a
  # Hash containing key value pairs of `:option_name => default_value`
  # (populated during object initialization).
  #
  # If use_separate_default_options is disabled, it will always be an empty
  # hash.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#244
  def default_config; end

  # If ClassMethods#use_separate_default_options is enabled, this will be a
  # Hash containing key value pairs of `:option_name => default_value`
  # (populated during object initialization).
  #
  # If use_separate_default_options is disabled, it will always be an empty
  # hash.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#244
  def default_config=(_arg0); end

  # Iterates through options declared as deprecated,
  # maps values to their replacement options,
  # and prints deprecation warnings.
  #
  # @return NilClass
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#394
  def handle_deprecated_options(show_deprecations); end

  # The option parser generated from the mixlib-cli DSL. +opt_parser+ can be
  # used to print a help message including the banner and any CLI options via
  # `puts opt_parser`.
  # === Returns
  # opt_parser<OptionParser>:: The option parser object.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#344
  def opt_parser; end

  # Gives the command line options definition as configured in the DSL. These
  # are used by #parse_options to generate the option parsing code. To get
  # the values supplied by the user, see #config.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#223
  def options; end

  # Gives the command line options definition as configured in the DSL. These
  # are used by #parse_options to generate the option parsing code. To get
  # the values supplied by the user, see #config.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#223
  def options=(_arg0); end

  # Parses an array, by default ARGV, for command line options (as configured at
  # the class level).
  # === Parameters
  # argv<Array>:: The array of arguments to parse; defaults to ARGV
  #
  # === Returns
  # argv<Array>:: Returns any un-parsed elements.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#304
  def parse_options(argv = T.unsafe(nil), show_deprecations: T.unsafe(nil)); end

  class << self
    # @private
    #
    # source://mixlib-cli//lib/mixlib/cli.rb#448
    def included(receiver); end
  end
end

# source://mixlib-cli//lib/mixlib/cli.rb#81
module Mixlib::CLI::ClassMethods
  # Change the banner.  Defaults to:
  #   Usage: #{0} (options)
  #
  # === Parameters
  # bstring<String>:: The string to set the banner to
  #
  # === Returns
  # @banner<String>:: The current banner
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#210
  def banner(bstring = T.unsafe(nil)); end

  # Declare a deprecated option
  #
  # Add a deprecated command line option.
  #
  # name<Symbol> :: The name of the deprecated option
  # replacement<Symbol> :: The name of the option that replaces this option.
  # long<String> :: The original long flag name, or flag name with argument, eg "--user USER"
  # short<String>  :: The original short-form flag name, eg "-u USER"
  # boolean<String> :: true if this is a boolean flag, eg "--[no-]option".
  # value_mapper<Proc/1> :: a block that accepts the original value from the deprecated option,
  #                   and converts it to a value suitable for the new option.
  #                   If not provided, the value provided to the deprecated option will be
  #                   assigned directly to the converted option.
  # keep<Boolean> :: Defaults to true, this ensures that `options[:deprecated_flag]` is
  #                  populated when the deprecated flag is used. If set to false,
  #                  only the value in `replacement` will be set.  Results undefined
  #                  if no replacement is provided. You can use this to enforce the transition
  #                  to non-deprecated keys in your code.
  #
  # === Returns
  # <Hash> :: The config hash for the created option.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#151
  def deprecated_option(name, replacement: T.unsafe(nil), long: T.unsafe(nil), short: T.unsafe(nil), boolean: T.unsafe(nil), value_mapper: T.unsafe(nil), keep: T.unsafe(nil)); end

  # Add a command line option.
  #
  # === Parameters
  # name<Symbol>:: The name of the option to add
  # args<Hash>:: A hash of arguments for the option, specifying how it should be parsed.
  #   Supported arguments:
  #     :short   - The short option, just like from optparse. Example: "-l LEVEL"
  #     :long    - The long option, just like from optparse. Example: "--level LEVEL"
  #     :description - The description for this item, just like from optparse.
  #     :default - A default value for this option.  Default values will be populated
  #     on parse into `config` or `default_default`, depending `use_separate_defaults`
  #     :boolean - indicates the flag is a boolean. You can use this if the flag takes no arguments
  #                The config value will be set to 'true' if the flag is provided on the CLI and this
  #                argument is set to true. The config value will be set to false only
  #                if it has a default value of false
  #     :required - When set, the option is required.  If the command is run without this option,
  #                it will print a message informing the user of the missing requirement, and exit. Default is false.
  #     :proc     - Proc that will be invoked if the human has specified this option.
  #                 Two forms are supported:
  #                 Proc/1 - provided value is passed in.
  #                 Proc/2 - first argument is provided value. Second is the cli flag option hash.
  #                 Both versions return the value to be assigned to the option.
  #     :show_options - this option is designated as one that shows all supported options/help when invoked.
  #     :exit     - exit your program with the exit code when this option is given. Example: 0
  #     :in       - array containing a list of valid values. The value provided at run-time for the option is
  #                 validated against this. If it is not in the list, it will print a message and exit.
  #     :on :head OR :tail - force this option to display at the beginning or end of the
  #                          option list, respectively
  # =
  # i
  #
  # @raise [ArgumentError]
  # @return [Hash] :: the config hash for the created option
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#123
  def option(name, args); end

  # Get the hash of current options.
  #
  # === Returns
  # @options<Hash>:: The current options hash.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#184
  def options; end

  # Set the current options hash
  #
  # === Parameters
  # val<Hash>:: The hash to set the options to
  #
  # === Returns
  # @options<Hash>:: The current options hash.
  #
  # @raise [ArgumentError]
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#196
  def options=(val); end

  # When this setting is set to +true+, default values supplied to the
  # mixlib-cli DSL will be stored in a separate Hash
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#84
  def use_separate_default_options(true_or_false); end

  # @return [Boolean]
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#88
  def use_separate_defaults?; end
end

# source://mixlib-cli//lib/mixlib/cli/formatter.rb#4
class Mixlib::CLI::Formatter
  class << self
    # Create a string that includes both versions (short/long) of a flag name
    # based on on whether short/long/both/neither are provided
    #
    # @param short [String] the short name of the option. Can be nil.
    # @param long [String] the long name of the option. Can be nil.
    # @return [String] the formatted flag name as described above
    #
    # source://mixlib-cli//lib/mixlib/cli/formatter.rb#11
    def combined_option_display_name(short, long); end

    # @param opt_array [Array]
    # @return [String] a friendly quoted list of items complete with "or"
    #
    # source://mixlib-cli//lib/mixlib/cli/formatter.rb#25
    def friendly_opt_list(opt_array); end
  end
end

# source://mixlib-cli//lib/mixlib/cli.rb#43
module Mixlib::CLI::InheritMethods
  # object:: Instance to clone
  # This method will return a "deep clone" of the provided
  # `object`. If the provided `object` is an enumerable type the
  # contents will be iterated and cloned as well.
  #
  # source://mixlib-cli//lib/mixlib/cli.rb#53
  def deep_dup(object); end

  # source://mixlib-cli//lib/mixlib/cli.rb#44
  def inherited(receiver); end
end
