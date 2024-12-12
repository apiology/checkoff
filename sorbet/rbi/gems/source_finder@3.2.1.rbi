# typed: strict

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `source_finder` gem.
# Please instead update this file by running `bin/tapioca gem source_finder`.


# SourceFinder finds source and documentation files within a project.
#
# source://source_finder//lib/source_finder/langs/ruby.rb#1
module SourceFinder; end

# Globber for JavaScript
#
# source://source_finder//lib/source_finder/langs/groovy.rb#3
module SourceFinder::GroovySourceFileGlobber
  # source://source_finder//lib/source_finder/langs/groovy.rb#11
  def extra_groovy_files_arr; end

  # Sets the attribute extra_groovy_files_arr
  #
  # @param value the value to set the attribute extra_groovy_files_arr to.
  #
  # source://source_finder//lib/source_finder/langs/groovy.rb#4
  def extra_groovy_files_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/groovy.rb#7
  def groovy_dirs_arr; end

  # Sets the attribute groovy_dirs_arr
  #
  # @param value the value to set the attribute groovy_dirs_arr to.
  #
  # source://source_finder//lib/source_finder/langs/groovy.rb#4
  def groovy_dirs_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/groovy.rb#15
  def groovy_file_extensions_arr; end

  # Sets the attribute groovy_file_extensions_arr
  #
  # @param value the value to set the attribute groovy_file_extensions_arr to.
  #
  # source://source_finder//lib/source_finder/langs/groovy.rb#4
  def groovy_file_extensions_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/groovy.rb#20
  def groovy_file_extensions_glob; end

  # source://source_finder//lib/source_finder/langs/groovy.rb#29
  def groovy_files_arr; end

  # source://source_finder//lib/source_finder/langs/groovy.rb#24
  def groovy_files_glob; end
end

# Globber for JavaScript
#
# source://source_finder//lib/source_finder/langs/js.rb#3
module SourceFinder::JsSourceFileGlobber
  # source://source_finder//lib/source_finder/langs/js.rb#11
  def extra_js_files_arr; end

  # Sets the attribute extra_js_files_arr
  #
  # @param value the value to set the attribute extra_js_files_arr to.
  #
  # source://source_finder//lib/source_finder/langs/js.rb#4
  def extra_js_files_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/js.rb#7
  def js_dirs_arr; end

  # Sets the attribute js_dirs_arr
  #
  # @param value the value to set the attribute js_dirs_arr to.
  #
  # source://source_finder//lib/source_finder/langs/js.rb#4
  def js_dirs_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/js.rb#15
  def js_file_extensions_arr; end

  # Sets the attribute js_file_extensions_arr
  #
  # @param value the value to set the attribute js_file_extensions_arr to.
  #
  # source://source_finder//lib/source_finder/langs/js.rb#4
  def js_file_extensions_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/js.rb#20
  def js_file_extensions_glob; end

  # source://source_finder//lib/source_finder/langs/js.rb#29
  def js_files_arr; end

  # source://source_finder//lib/source_finder/langs/js.rb#24
  def js_files_glob; end
end

# Brings in command-line options to configure SourceFinder--usable
# with the ruby OptionParser class, brought in with 'require
# "optparse"'
#
# source://source_finder//lib/source_finder/option_parser.rb#7
class SourceFinder::OptionParser
  # source://source_finder//lib/source_finder/option_parser.rb#28
  def add_exclude_glob_option(opts, options); end

  # source://source_finder//lib/source_finder/option_parser.rb#20
  def add_glob_option(opts, options); end

  # source://source_finder//lib/source_finder/option_parser.rb#35
  def add_options(opts, options); end

  # source://source_finder//lib/source_finder/option_parser.rb#16
  def default_source_files_exclude_glob; end

  # source://source_finder//lib/source_finder/option_parser.rb#12
  def default_source_files_glob; end

  # source://source_finder//lib/source_finder/option_parser.rb#8
  def fresh_globber; end
end

# Globber for Python
#
# source://source_finder//lib/source_finder/langs/python.rb#3
module SourceFinder::PythonSourceFileGlobber
  # source://source_finder//lib/source_finder/langs/python.rb#11
  def extra_python_files_arr; end

  # Sets the attribute extra_python_files_arr
  #
  # @param value the value to set the attribute extra_python_files_arr to.
  #
  # source://source_finder//lib/source_finder/langs/python.rb#4
  def extra_python_files_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/python.rb#7
  def python_dirs_arr; end

  # Sets the attribute python_dirs_arr
  #
  # @param value the value to set the attribute python_dirs_arr to.
  #
  # source://source_finder//lib/source_finder/langs/python.rb#4
  def python_dirs_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/python.rb#15
  def python_file_extensions_arr; end

  # Sets the attribute python_file_extensions_arr
  #
  # @param value the value to set the attribute python_file_extensions_arr to.
  #
  # source://source_finder//lib/source_finder/langs/python.rb#4
  def python_file_extensions_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/python.rb#20
  def python_file_extensions_glob; end

  # source://source_finder//lib/source_finder/langs/python.rb#29
  def python_files_arr; end

  # source://source_finder//lib/source_finder/langs/python.rb#24
  def python_files_glob; end
end

# Globber for Ruby
#
# source://source_finder//lib/source_finder/langs/ruby.rb#3
module SourceFinder::RubySourceFileGlobber
  # source://source_finder//lib/source_finder/langs/ruby.rb#11
  def extra_ruby_files_arr; end

  # Sets the attribute extra_ruby_files_arr
  #
  # @param value the value to set the attribute extra_ruby_files_arr to.
  #
  # source://source_finder//lib/source_finder/langs/ruby.rb#4
  def extra_ruby_files_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/ruby.rb#7
  def ruby_dirs_arr; end

  # Sets the attribute ruby_dirs_arr
  #
  # @param value the value to set the attribute ruby_dirs_arr to.
  #
  # source://source_finder//lib/source_finder/langs/ruby.rb#4
  def ruby_dirs_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/ruby.rb#15
  def ruby_file_extensions_arr; end

  # Sets the attribute ruby_file_extensions_arr
  #
  # @param value the value to set the attribute ruby_file_extensions_arr to.
  #
  # source://source_finder//lib/source_finder/langs/ruby.rb#4
  def ruby_file_extensions_arr=(_arg0); end

  # source://source_finder//lib/source_finder/langs/ruby.rb#20
  def ruby_file_extensions_glob; end

  # source://source_finder//lib/source_finder/langs/ruby.rb#29
  def ruby_files_arr; end

  # source://source_finder//lib/source_finder/langs/ruby.rb#24
  def ruby_files_glob; end
end

# Give configuration, finds source file locations by using an
# inclusion and exclusion glob
#
# source://source_finder//lib/source_finder/source_file_globber.rb#9
class SourceFinder::SourceFileGlobber
  include ::SourceFinder::RubySourceFileGlobber
  include ::SourceFinder::JsSourceFileGlobber
  include ::SourceFinder::PythonSourceFileGlobber
  include ::SourceFinder::GroovySourceFileGlobber

  # @return [SourceFileGlobber] a new instance of SourceFileGlobber
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#20
  def initialize(globber: T.unsafe(nil)); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#100
  def arr2glob(arr); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#59
  def default_source_file_extensions_arr; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#39
  def default_source_files_exclude_glob; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#72
  def doc_file_extensions_arr; end

  # @return [Boolean]
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#114
  def emacs_lockfile?(filename); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#43
  def exclude_files_arr; end

  # See README.md for documentation on these configuration parameters.
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#11
  def exclude_files_arr=(_arg0); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#118
  def exclude_garbage(files_arr); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#32
  def extra_source_files_arr; end

  # See README.md for documentation on these configuration parameters.
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#11
  def extra_source_files_arr=(_arg0); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#110
  def make_extensions_arr(arr_var, default_arr); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#104
  def make_files_glob(extra_source_files_arr, dirs_arr, extensions_glob); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#80
  def source_and_doc_file_extensions_arr; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#84
  def source_and_doc_file_extensions_glob; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#95
  def source_and_doc_files_glob; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#27
  def source_dirs_arr; end

  # See README.md for documentation on these configuration parameters.
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#11
  def source_dirs_arr=(_arg0); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#63
  def source_file_extensions_arr; end

  # See README.md for documentation on these configuration parameters.
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#11
  def source_file_extensions_arr=(_arg0); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#76
  def source_file_extensions_glob; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#122
  def source_files_arr; end

  # source://source_finder//lib/source_finder/source_file_globber.rb#49
  def source_files_exclude_glob; end

  # See README.md for documentation on these configuration parameters.
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#11
  def source_files_exclude_glob=(_arg0); end

  # source://source_finder//lib/source_finder/source_file_globber.rb#88
  def source_files_glob; end

  # See README.md for documentation on these configuration parameters.
  #
  # source://source_finder//lib/source_finder/source_file_globber.rb#11
  def source_files_glob=(_arg0); end
end
