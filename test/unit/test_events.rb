# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/events'

class TestEvents < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :asana_event_filter_class)

  let_mock :filters, :event,
           :asana_event_filter

  # @return [void]
  def mock_filter_asana_events_true
    # @sg-ignore asana_event_filter_class from def_delegators; asana_event_filter/event from let_mock
    asana_event_filter_class.expects(:new).with(filters:).returns(asana_event_filter)
    # @sg-ignore asana_event_filter/event from let_mock
    asana_event_filter.expects(:matches?).with(event).returns(true)
  end

  # @return [void]
  def test_filter_asana_events_true
    events = get_test_object do
      mock_filter_asana_events_true
    end

    # @sg-ignore event from let_mock
    assert_equal([event], events.filter_asana_events(filters, [event]))
  end

  # @return [void]
  def test_filter_asana_events_false
    events = get_test_object do
      # @sg-ignore asana_event_filter_class from def_delegators
      asana_event_filter_class.expects(:new).with(filters:).returns(asana_event_filter)
      # @sg-ignore asana_event_filter/event from let_mock
      asana_event_filter.expects(:matches?).with(event).returns(false)
    end

    # @sg-ignore filters/event from let_mock
    assert_empty(events.filter_asana_events(filters, [event]))
  end

  # @return [Class]
  def class_under_test
    Checkoff::Events
  end

  # @return [Hash{Symbol => Class}]
  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      sections: Checkoff::Sections,
      projects: Checkoff::Projects,
      asana_event_enrichment: Checkoff::Internal::AsanaEventEnrichment,
      tasks: Checkoff::Tasks,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  # @return [Hash{Symbol => Class}]
  def respond_like
    {
      asana_event_filter_class: Checkoff::Internal::AsanaEventFilter,
    }
  end
end
