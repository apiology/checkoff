# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `rubocop-yard` gem.
# Please instead update this file by running `bin/tapioca gem rubocop-yard`.


# source://rubocop-yard//lib/rubocop/yard/version.rb#3
module RuboCop; end

# source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#4
module RuboCop::Cop; end

# source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#5
module RuboCop::Cop::YARD; end

# @example EnforcedStyle short
#
#   # bad
#   # @param [Hash{KeyType => ValueType}]
#
#   # bad
#   # @param [Array(String)]
#
#   # bad
#   # @param [Array<String>]
#
#   # good
#   # @param [{KeyType => ValueType}]
#
#   # good
#   # @param [(String)]
#
#   # good
#   # @param [<String>]
# @example EnforcedStyle long (default)
#   # bad
#   # @param [{KeyType => ValueType}]
#
#   # bad
#   # @param [(String)]
#
#   # bad
#   # @param [<String>]
#
#   # good
#   # @param [Hash{KeyType => ValueType}]
#
#   # good
#   # @param [Array(String)]
#
#   # good
#   # @param [Array<String>]
#
# source://rubocop-yard//lib/rubocop/cop/yard/collection_style.rb#44
class RuboCop::Cop::YARD::CollectionStyle < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::YARD::Helper
  include ::RuboCop::Cop::RangeHelp
  include ::RuboCop::Cop::ConfigurableEnforcedStyle
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_style.rb#50
  def on_new_investigation; end

  private

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_style.rb#77
  def bad_style; end

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_style.rb#61
  def check(comment); end

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_style.rb#73
  def ignore_whitespace(str); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/collection_style.rb#85
  def include_yard_tag?(comment); end
end

# @example common
#   # bad
#   # @param [Hash<Symbol, String>]
#
#   # bad
#   # @param [Hash(String)]
#
#   # bad
#   # @param [Array{Symbol => String}]
#
#   # good
#   # @param [Hash{Symbol => String}]
#
#   # good
#   # @param [Array(String)]
#
#   # good
#   # @param [Hash{Symbol => String}]
#
# source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#24
class RuboCop::Cop::YARD::CollectionType < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::YARD::Helper
  include ::RuboCop::Cop::RangeHelp
  include ::RuboCop::Cop::ConfigurableEnforcedStyle
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#30
  def on_new_investigation; end

  private

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#42
  def check_mismatch_collection_type(comment, docstring); end

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#48
  def check_mismatch_collection_type_one(comment, types_explainer); end

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#111
  def correct_tag_type(corrector, comment, types_explainer); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#115
  def include_yard_tag?(comment); end

  # source://rubocop-yard//lib/rubocop/cop/yard/collection_type.rb#119
  def tag_range_for_comment(comment); end
end

# source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#6
module RuboCop::Cop::YARD::Helper
  # source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#79
  def build_docstring(preceding_lines); end

  # source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#22
  def each_types_explainer(docstring, &block); end

  # source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#7
  def extract_tag_types(tag); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#75
  def inline_comment?(comment); end

  # source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#18
  def parse_type(type); end

  # source://rubocop-yard//lib/rubocop/cop/yard/helper.rb#36
  def styled_string(types_explainer); end
end

# @example meaningless tag
#   # bad
#   # @param [String] foo
#   # @option bar baz [String]
#   class Foo
#
#   # bad
#   # @param [String] foo
#   # @option bar baz [String]
#   CONST = 1
#
#   # good
#   class Foo
#
#   # good
#   CONST = 1
#
# source://rubocop-yard//lib/rubocop/cop/yard/meaningless_tag.rb#22
class RuboCop::Cop::YARD::MeaninglessTag < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::YARD::Helper
  include ::RuboCop::Cop::RangeHelp
  include ::RuboCop::Cop::DocumentationComment
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-yard//lib/rubocop/cop/yard/meaningless_tag.rb#34
  def check(node); end

  # source://rubocop-yard//lib/rubocop/cop/yard/meaningless_tag.rb#28
  def on_casgn(node); end

  # source://rubocop-yard//lib/rubocop/cop/yard/meaningless_tag.rb#28
  def on_class(node); end

  # source://rubocop-yard//lib/rubocop/cop/yard/meaningless_tag.rb#28
  def on_module(node); end
end

# @example mismatch name
#   # bad
#   # @param [void] baz
#   # @option opt aaa [void]
#   def foo(bar, opts = {})
#   end
#
#   # good
#   # @param [void] bar
#   # @param [Array] arg
#   # @option opts aaa [void]
#   def foo(bar, opts = {}, *arg)
#   end
#
# source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#19
class RuboCop::Cop::YARD::MismatchName < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::YARD::Helper
  include ::RuboCop::Cop::RangeHelp
  include ::RuboCop::Cop::DocumentationComment
  extend ::RuboCop::Cop::AutoCorrector

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#25
  def on_def(node); end

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#25
  def on_defs(node); end

  private

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#172
  def add_offense_to_tag(node, comment, tag); end

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#150
  def cop_config_prototype_name; end

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#158
  def each_tags_by_docstring(tag_names, docstring); end

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#164
  def find_by_tag(preceding_lines, tag, i); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#189
  def include_overload_tag?(docstring); end

  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#119
  def literal_to_yard_type(node); end

  # @param argument [RuboCop::AST::ArgNode]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/mismatch_name.rb#99
  def tag_prototype(argument); end
end

# source://rubocop-yard//lib/rubocop/cop/yard/tag_type_position.rb#6
class RuboCop::Cop::YARD::TagTypePosition < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::YARD::Helper
  include ::RuboCop::Cop::RangeHelp

  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_position.rb#10
  def on_new_investigation; end

  private

  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_position.rb#22
  def check(comment); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_position.rb#33
  def include_yard_tag?(comment); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_position.rb#37
  def include_yard_tag_type?(comment); end
end

# @example tag type
#   # bad
#   # @param [Integer String]
#
#   # good
#   # @param [Integer, String]
#
# source://rubocop-yard//lib/rubocop/cop/yard/tag_type_syntax.rb#12
class RuboCop::Cop::YARD::TagTypeSyntax < ::RuboCop::Cop::Base
  include ::RuboCop::Cop::YARD::Helper
  include ::RuboCop::Cop::RangeHelp

  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_syntax.rb#16
  def on_new_investigation; end

  private

  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_syntax.rb#27
  def check(comment); end

  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_syntax.rb#38
  def check_syntax_error(comment); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_syntax.rb#46
  def include_yard_tag?(comment); end

  # source://rubocop-yard//lib/rubocop/cop/yard/tag_type_syntax.rb#50
  def tag_range_for_comment(comment); end
end

# source://rubocop-yard//lib/rubocop/yard/version.rb#4
module RuboCop::YARD; end

# source://rubocop-yard//lib/rubocop/yard.rb#11
RuboCop::YARD::CONFIG = T.let(T.unsafe(nil), Hash)

# source://rubocop-yard//lib/rubocop/yard.rb#10
RuboCop::YARD::CONFIG_DEFAULT = T.let(T.unsafe(nil), Pathname)

# source://rubocop-yard//lib/rubocop/yard.rb#7
class RuboCop::YARD::Error < ::StandardError; end

# Your code goes here...
#
# source://rubocop-yard//lib/rubocop/yard.rb#9
RuboCop::YARD::PROJECT_ROOT = T.let(T.unsafe(nil), Pathname)

# A plugin that integrates RuboCop Performance with RuboCop's plugin system.
#
# source://rubocop-yard//lib/rubocop/yard/plugin.rb#8
class RuboCop::YARD::Plugin < ::LintRoller::Plugin
  # source://rubocop-yard//lib/rubocop/yard/plugin.rb#9
  def about; end

  # source://rubocop-yard//lib/rubocop/yard/plugin.rb#22
  def rules(_context); end

  # @return [Boolean]
  #
  # source://rubocop-yard//lib/rubocop/yard/plugin.rb#18
  def supported?(context); end
end

# source://rubocop-yard//lib/rubocop/yard/version.rb#5
RuboCop::YARD::VERSION = T.let(T.unsafe(nil), String)
