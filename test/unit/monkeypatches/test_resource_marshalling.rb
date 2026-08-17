# typed: true
# frozen_string_literal: true

require 'asana'
require_relative '../test_helper'
require_relative '../../../lib/checkoff/monkeypatches/resource_marshalling'

class TestResourceMarshalling < Minitest::Test
  # Marshal refuses instances of anonymous classes and anything holding a
  # proc, so the client placeholder is a plain dumpable value.
  STUB_CLIENT = 'stub-client'

  # Accessors for data keys are synthesized at runtime by Asana's
  # method_missing, so this one is only reachable through public_send.
  UNDECLARED_FIELD = :some_undeclared_field

  DATA = { 'gid' => '123', 'some_undeclared_field' => 'bar' }.freeze

  # @return [void]
  def test_round_trip_survives_accessor_singleton_methods
    task = build_task

    assert_equal('bar', task.public_send(UNDECLARED_FIELD))
    assert_includes(task.singleton_methods, UNDECLARED_FIELD)

    copy = marshal_round_trip(task)

    assert_equal(DATA, copy.to_h)
    assert_equal('bar', copy.public_send(UNDECLARED_FIELD))
    assert_equal(STUB_CLIENT, copy.instance_variable_get(:@_client))
  end

  # @return [void]
  def test_marshal_dump_exposes_data_and_client
    task = build_task

    dumped = task.marshal_dump

    assert_equal(DATA, dumped.fetch('data'))
    assert_equal(STUB_CLIENT, dumped.fetch('client'))
  end

  # @return [void]
  def test_marshal_load_populates_ivars_for_data_keys
    task = Asana::Resources::Task.allocate

    task.marshal_load('client' => STUB_CLIENT, 'data' => DATA)

    assert_equal('123', task.gid)
    assert_equal('bar', task.instance_variable_get(:@some_undeclared_field))
  end

  private

  # @param task [Asana::Resources::Task]
  # @return [Asana::Resources::Task]
  def marshal_round_trip(task)
    copy = Marshal.load(Marshal.dump(task))
    raise "Expected a Task back, got #{copy.class}" unless copy.is_a?(Asana::Resources::Task)

    copy
  end

  # @return [Asana::Resources::Task]
  def build_task
    Asana::Resources::Task.new(DATA.dup, client: STUB_CLIENT)
  end
end
