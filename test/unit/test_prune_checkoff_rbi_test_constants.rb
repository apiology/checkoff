# typed: true
# frozen_string_literal: true

require 'minitest/autorun'
require 'checkoff/prune_rbi_test_constants'

class TestPruneCheckoffRbiTestConstants < Minitest::Test
  SAMPLE = <<~RBI
    module TestDate
      TIME_BY_PERIOD = T.let({ a: '1' }.freeze, T.untyped)
    end

    class TestTasks < BaseAsana
      extend Forwardable
      TIME_BY_PERIOD = T.let({
      two_am: '02:00:20',
      }.freeze, T.untyped)

      sig { void }
      def foo; end
    end
  RBI

  def test_prunes_subclass_constant
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'checkoff.rbi')
      File.write(path, SAMPLE)

      Checkoff::PruneRbiTestConstants.call(path)

      text = File.read(path)

      assert_equal 1, text.scan('TIME_BY_PERIOD').length
      refute_match(/class TestTasks < BaseAsana\n  extend Forwardable\n  TIME_BY_PERIOD/m, text)

      assert_match(/class TestTasks < BaseAsana\n  extend Forwardable\n.*sig/m, text)
    end
  end

  def test_noop_when_nothing_to_prune
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'checkoff.rbi')
      File.write(path, "module TestDate\n  TIME_BY_PERIOD = T.let({}.freeze, T.untyped)\nend\n")

      Checkoff::PruneRbiTestConstants.call(path)

      unchanged = "module TestDate\n  TIME_BY_PERIOD = T.let({}.freeze, T.untyped)\nend\n"

      assert_equal unchanged, File.read(path)
    end
  end
end
