# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/events'

class TestEvents < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :asana_event_filter_class)

  let_mock :filters, :event,
           :asana_event_filter

  def mock_filter_asana_events_true
    asana_event_filter_class.expects(:new).with(filters: filters).returns(asana_event_filter)
    asana_event_filter.expects(:matches?).with(event).returns(true)
  end

  def test_filter_asana_events_true
    events = get_test_object do
      mock_filter_asana_events_true
    end

    assert_equal([event], events.filter_asana_events(filters, [event]))
  end

  def test_filter_asana_events_false
    events = get_test_object do
      asana_event_filter_class.expects(:new).with(filters: filters).returns(asana_event_filter)
      asana_event_filter.expects(:matches?).with(event).returns(false)
    end

    assert_empty(events.filter_asana_events(filters, [event]))
  end

  def class_under_test
    Checkoff::Events
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {
      asana_event_filter_class: Checkoff::Internal::AsanaEventFilter,
    }
  end
end
