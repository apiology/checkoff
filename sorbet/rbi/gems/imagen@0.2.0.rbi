# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `imagen` gem.
# Please instead update this file by running `bin/tapioca gem imagen`.


# Base module
#
# source://imagen//lib/imagen/ast/parser.rb#3
module Imagen
  class << self
    # source://imagen//lib/imagen.rb#14
    def from_local(dir); end

    # source://imagen//lib/imagen.rb#18
    def from_remote(repo_url); end

    # Returns the value of attribute parser_version.
    #
    # source://imagen//lib/imagen/ast/parser.rb#7
    def parser_version; end

    # Sets the attribute parser_version
    #
    # @param value the value to set the attribute parser_version to.
    #
    # source://imagen//lib/imagen/ast/parser.rb#7
    def parser_version=(_arg0); end
  end
end

# source://imagen//lib/imagen/ast/parser.rb#27
module Imagen::AST; end

# An AST Builder for ruby parser.
#
# source://imagen//lib/imagen/ast/builder.rb#9
class Imagen::AST::Builder < ::Parser::Builders::Default
  # This is a work around for parsing ruby code that with invlalid UTF-8
  # https://github.com/whitequark/parser/issues/283
  #
  # source://imagen//lib/imagen/ast/builder.rb#12
  def string_value(token); end
end

# source://imagen//lib/imagen/ast/parser.rb#28
class Imagen::AST::Parser
  # @param parser_version [String] ruby syntax version
  # @return [Parser] a new instance of Parser
  #
  # source://imagen//lib/imagen/ast/parser.rb#38
  def initialize(parser_version = T.unsafe(nil)); end

  # source://imagen//lib/imagen/ast/parser.rb#55
  def parse(input, file = T.unsafe(nil)); end

  # source://imagen//lib/imagen/ast/parser.rb#51
  def parse_file(filename); end

  # source://imagen//lib/imagen/ast/parser.rb#61
  def parser; end

  private

  # @raise [ArgumentError]
  #
  # source://imagen//lib/imagen/ast/parser.rb#71
  def validate_version(parser_version); end

  class << self
    # source://imagen//lib/imagen/ast/parser.rb#33
    def parse(input, file = T.unsafe(nil)); end

    # source://imagen//lib/imagen/ast/parser.rb#29
    def parse_file(filename); end
  end
end

# source://imagen//lib/imagen/ast/parser.rb#10
Imagen::AVAILABLE_RUBY_VERSIONS = T.let(T.unsafe(nil), Array)

# Responsible for cloning a Git repository into a given tempdir
#
# source://imagen//lib/imagen/clone.rb#10
class Imagen::Clone
  # @raise [ArgumentError]
  # @return [Clone] a new instance of Clone
  #
  # source://imagen//lib/imagen/clone.rb#17
  def initialize(repo_url, dirname); end

  # Returns the value of attribute dir.
  #
  # source://imagen//lib/imagen/clone.rb#15
  def dir; end

  # source://imagen//lib/imagen/clone.rb#24
  def perform; end

  # Returns the value of attribute repo_url.
  #
  # source://imagen//lib/imagen/clone.rb#15
  def repo_url; end

  class << self
    # source://imagen//lib/imagen/clone.rb#11
    def perform(repo_url, dir); end
  end
end

# source://imagen//lib/imagen.rb#12
Imagen::EXCLUDE_RE = T.let(T.unsafe(nil), Regexp)

# Generic clone error
#
# source://imagen//lib/imagen/clone.rb#7
class Imagen::GitError < ::StandardError; end

# source://imagen//lib/imagen/node.rb#7
module Imagen::Node; end

# Abstract base class
#
# source://imagen//lib/imagen/node.rb#9
class Imagen::Node::Base
  # @return [Base] a new instance of Base
  #
  # source://imagen//lib/imagen/node.rb#14
  def initialize; end

  # Returns the value of attribute ast_node.
  #
  # source://imagen//lib/imagen/node.rb#10
  def ast_node; end

  # source://imagen//lib/imagen/node.rb#22
  def build_from_ast(ast_node); end

  # Returns the value of attribute children.
  #
  # source://imagen//lib/imagen/node.rb#10
  def children; end

  # @return [Boolean]
  #
  # source://imagen//lib/imagen/node.rb#26
  def empty_def?; end

  # source://imagen//lib/imagen/node.rb#30
  def file_path; end

  # source://imagen//lib/imagen/node.rb#61
  def find_all(matcher, ret = T.unsafe(nil)); end

  # source://imagen//lib/imagen/node.rb#34
  def first_line; end

  # @raise [NotImplementedError]
  #
  # source://imagen//lib/imagen/node.rb#18
  def human_name; end

  # source://imagen//lib/imagen/node.rb#42
  def last_line; end

  # source://imagen//lib/imagen/node.rb#38
  def line_numbers; end

  # Returns the value of attribute name.
  #
  # source://imagen//lib/imagen/node.rb#10
  def name; end

  # source://imagen//lib/imagen/node.rb#46
  def source; end

  # source://imagen//lib/imagen/node.rb#54
  def source_lines; end

  # source://imagen//lib/imagen/node.rb#50
  def source_lines_with_numbers; end
end

# Represents a Ruby block
#
# source://imagen//lib/imagen/node.rb#174
class Imagen::Node::Block < ::Imagen::Node::Base
  # source://imagen//lib/imagen/node.rb#175
  def build_from_ast(_ast_node); end

  # source://imagen//lib/imagen/node.rb#180
  def human_name; end

  private

  # source://imagen//lib/imagen/node.rb#186
  def args_list; end
end

# Represents a Ruby class method
#
# source://imagen//lib/imagen/node.rb#150
class Imagen::Node::CMethod < ::Imagen::Node::Base
  # source://imagen//lib/imagen/node.rb#151
  def build_from_ast(ast_node); end

  # source://imagen//lib/imagen/node.rb#156
  def human_name; end
end

# Represents a Ruby class
#
# source://imagen//lib/imagen/node.rb#138
class Imagen::Node::Class < ::Imagen::Node::Base
  # source://imagen//lib/imagen/node.rb#139
  def build_from_ast(ast_node); end

  # source://imagen//lib/imagen/node.rb#144
  def human_name; end
end

# Represents a Ruby instance method
#
# source://imagen//lib/imagen/node.rb#162
class Imagen::Node::IMethod < ::Imagen::Node::Base
  # source://imagen//lib/imagen/node.rb#163
  def build_from_ast(ast_node); end

  # source://imagen//lib/imagen/node.rb#168
  def human_name; end
end

# Represents a Ruby module
#
# source://imagen//lib/imagen/node.rb#126
class Imagen::Node::Module < ::Imagen::Node::Base
  # source://imagen//lib/imagen/node.rb#127
  def build_from_ast(ast_node); end

  # source://imagen//lib/imagen/node.rb#132
  def human_name; end
end

# Root node for a given directory
#
# source://imagen//lib/imagen/node.rb#70
class Imagen::Node::Root < ::Imagen::Node::Base
  # source://imagen//lib/imagen/node.rb#90
  def build_from_ast(ast_node); end

  # source://imagen//lib/imagen/node.rb#80
  def build_from_dir(dir); end

  # source://imagen//lib/imagen/node.rb#73
  def build_from_file(path); end

  # Returns the value of attribute dir.
  #
  # source://imagen//lib/imagen/node.rb#71
  def dir; end

  # TODO: fix wrong inheritance
  #
  # source://imagen//lib/imagen/node.rb#100
  def file_path; end

  # source://imagen//lib/imagen/node.rb#104
  def first_line; end

  # source://imagen//lib/imagen/node.rb#95
  def human_name; end

  # source://imagen//lib/imagen/node.rb#108
  def last_line; end

  # source://imagen//lib/imagen/node.rb#112
  def source; end

  private

  # source://imagen//lib/imagen/node.rb#118
  def list_files; end
end

# RemoteBuilder is responsible for wrapping all operations to create code
# structure for a remote git repository.
#
# source://imagen//lib/imagen/remote_builder.rb#9
class Imagen::RemoteBuilder
  # @return [RemoteBuilder] a new instance of RemoteBuilder
  #
  # source://imagen//lib/imagen/remote_builder.rb#12
  def initialize(repo_url); end

  # source://imagen//lib/imagen/remote_builder.rb#17
  def build; end

  # Returns the value of attribute dir.
  #
  # source://imagen//lib/imagen/remote_builder.rb#10
  def dir; end

  # Returns the value of attribute repo_url.
  #
  # source://imagen//lib/imagen/remote_builder.rb#10
  def repo_url; end

  private

  # source://imagen//lib/imagen/remote_builder.rb#24
  def teardown; end
end

# AST Traversal that calls respective builder methods from Imagen::Node
#
# source://imagen//lib/imagen/visitor.rb#5
class Imagen::Visitor
  # Returns the value of attribute current_root.
  #
  # source://imagen//lib/imagen/visitor.rb#14
  def current_root; end

  # Returns the value of attribute file_path.
  #
  # source://imagen//lib/imagen/visitor.rb#14
  def file_path; end

  # Returns the value of attribute root.
  #
  # source://imagen//lib/imagen/visitor.rb#14
  def root; end

  # source://imagen//lib/imagen/visitor.rb#21
  def traverse(ast_node, parent); end

  # This method reeks of :reek:UtilityFunction
  #
  # source://imagen//lib/imagen/visitor.rb#29
  def visit(ast_node, parent); end

  class << self
    # source://imagen//lib/imagen/visitor.rb#16
    def traverse(ast, root); end
  end
end

# source://imagen//lib/imagen/visitor.rb#6
Imagen::Visitor::TYPES = T.let(T.unsafe(nil), Hash)
