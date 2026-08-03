# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/internal/asana_event_enrichment'

class TestAsanaEventEnrichment < ClassTest
  extend Forwardable

  # @!parse
  #  # @return [Checkoff::Internal::AsanaEventEnrichment]
  #  def get_test_object; end

  def_delegators(:@mocks, :resources, :tasks)

  typed_let_mock :task, Asana::Resources::Task
  typed_let_mock :resource, Asana::Resources::Resource

  # @return [void]
  def test_enrich_webhook_subscription_nil
    enrichment = get_test_object

    # @sg-ignore literal nil infers as NilClass, not the declared nil type -- same
    #   NilClass-vs-nil distinctness gap seen elsewhere in this codebase
    assert_nil(enrichment.enrich_webhook_subscription!(nil))
  end

  # @return [void]
  def test_enrich_webhook_subscription
    enrichment = get_test_object do
      resources.expects(:resource_by_gid).with('789', resource_type: nil).returns([resource, 'task'])
      resource.expects(:name).returns('Some Resource').at_least_once
    end

    webhook_subscription = {
      'resource' => '789',
      'filters' => [{}],
    }
    enrichment.enrich_webhook_subscription!(webhook_subscription)

    assert_equal('Some Resource', webhook_subscription.fetch('checkoff:enriched:name'))
    assert_equal('task', webhook_subscription.fetch('checkoff:enriched:resource_type'))
  end

  # @return [void]
  def test_enrich_webhook_subscription_no_filters
    enrichment = get_test_object do
      resources.expects(:resource_by_gid).with('789', resource_type: nil).returns([resource, 'task'])
      resource.expects(:name).returns('Some Resource').at_least_once
    end

    webhook_subscription = { 'resource' => '789' }
    enrichment.enrich_webhook_subscription!(webhook_subscription)

    assert_equal('Some Resource', webhook_subscription.fetch('checkoff:enriched:name'))
  end

  # @return [void]
  def test_enrich_filter_parent_gid_found
    enrichment = get_test_object do
      resources.expects(:resource_by_gid).with('123', resource_type: nil).returns([resource, 'task'])
      resource.expects(:name).returns('Some Task').at_least_once
    end

    filter = { 'checkoff:parent.gid' => '123' }
    enrichment.send(:enrich_filter_parent_gid!, filter)

    assert_equal('Some Task', filter.fetch('checkoff:enriched:parent.name'))
    assert_equal('task', filter.fetch('checkoff:enriched:parent.resource_type'))
  end

  # @return [void]
  def test_enrich_filter_parent_gid_absent
    enrichment = get_test_object

    filter = {}
    enrichment.send(:enrich_filter_parent_gid!, filter)

    assert_empty(filter)
  end

  # @return [void]
  def test_enrich_filter_resource_found
    enrichment = get_test_object do
      tasks.expects(:task_by_gid).with('456').returns(task)
      task.expects(:name).returns('Some Task Name').at_least_once
    end

    filter = { 'checkoff:resource.gid' => '456' }
    enrichment.send(:enrich_filter_resource!, filter)

    assert_equal('Some Task Name', filter.fetch('checkoff:enriched:resource.name'))
  end

  # @return [void]
  def test_enrich_filter_resource_absent
    enrichment = get_test_object

    filter = {}
    enrichment.send(:enrich_filter_resource!, filter)

    assert_empty(filter)
  end

  # @return [void]
  def class_under_test
    Checkoff::Internal::AsanaEventEnrichment
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      workspaces: Checkoff::Workspaces,
      tasks: Checkoff::Tasks,
      sections: Checkoff::Sections,
      projects: Checkoff::Projects,
      resources: Checkoff::Resources,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
