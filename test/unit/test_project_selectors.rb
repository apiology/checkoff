# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/project_selectors'

class TestProjectSelectors < ClassTest
  # @!parse
  #  # @return [Checkoff::ProjectSelectors]
  #  def get_test_object; end

  typed_delegate :projects, Checkoff::Projects
  typed_delegate :workspaces, Checkoff::Workspaces
  typed_delegate :portfolios, Checkoff::Portfolios
  typed_delegate :client, Asana::Client

  typed_mock :project, Asana::Resources::Project

  # @return [void]
  def test_filter_via_custom_field_value_contain_any_value_false
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [],
      'display_value' => 'something else',
    }
    project_selectors = get_test_object do
      mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      project.expects(:custom_fields).returns(custom_fields)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [{ 'name' => 'timeline', 'enabled' => true }],
      'display_value' => 'timeline',
    }
    project_selectors = get_test_object do
      mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true_single_in_multi_enum
    custom_field = {
      'name' => 'Project attributes',
      'enabled' => true,
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [{ 'name' => 'timeline' }],
      'display_value' => 'timeline',
    }
    project_selectors = get_test_object do
      mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_true_multiple
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [
        { 'name' => 'timeline', 'enabled' => true },
        { 'name' => 'something else', 'enabled' => true },
      ],
      'display_value' => 'timeline,something else',
    }
    project_selectors = get_test_object do
      mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      project.expects(:custom_fields).returns(custom_fields)
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_values_contain_any_value_false_nothing_set
    custom_field = {
      'name' => 'Project attributes',
      'resource_subtype' => 'multi_enum',
      'multi_enum_values' => [],
      'display_value' => 'timeline,something else',
    }
    project_selectors = get_test_object do
      mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = [custom_field]
      project.expects(:custom_fields).returns(custom_fields)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_custom_field_value_contains_any_value_no_custom_field_false
    project_selectors = get_test_object do
      mocks[:custom_fields] = Checkoff::CustomFields.new(client:)
      custom_fields = []
      project.expects(:custom_fields).returns(custom_fields).at_least(1)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:custom_field_value_contains_any_value?, 'Project attributes',
                                                          ['timeline']]))
  end

  # @return [void]
  def test_filter_via_due_date_false
    project_selectors = get_test_object do
      project.expects(:due_date).returns('2099-01-01').at_least(1)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:nil?, [:due_date]]))
  end

  # @return [void]
  def test_filter_via_ready_false
    project_selectors = get_test_object do
      projects.expects(:project_ready?).with(project, period: :now_or_before)
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:ready?]))
  end

  # @return [void]
  def stub_default_workspace_lookup
    workspace = mock('workspace')
    workspace.stubs(:name).returns('My Workspace')
    project.expects(:workspace).returns(nil)
    workspaces.expects(:default_workspace).returns(workspace)
  end

  # @param matching_project_name [String]
  # @return [void]
  def stub_in_portfolio_named(matching_project_name)
    stub_default_workspace_lookup
    matching_project = mock('matching_project')
    matching_project.stubs(:name).returns(matching_project_name)
    portfolios
      .expects(:projects_in_portfolio)
      .with('My Workspace', 'My Portfolio', extra_project_fields: [])
      .returns([matching_project])
    project.expects(:name).returns('My Project')
  end

  # @return [void]
  def test_filter_via_in_portfolio_named_true
    project_selectors = get_test_object do
      stub_in_portfolio_named('My Project')
    end

    assert(project_selectors.filter_via_project_selector(project,
                                                         [:in_portfolio_named?, 'My Portfolio']))
  end

  # @return [void]
  def test_filter_via_in_portfolio_named_false
    project_selectors = get_test_object do
      stub_in_portfolio_named('Some Other Project')
    end

    refute(project_selectors.filter_via_project_selector(project,
                                                         [:in_portfolio_named?, 'My Portfolio']))
  end

  # @return [void]
  def test_bogus_raises
    project_selectors = get_test_object

    e = assert_raises(RuntimeError) { project_selectors.filter_via_project_selector(project, [:bogus]) }

    assert_match(/Syntax issue trying to handle/, e.message)
  end

  # @return [Class<Checkoff::ProjectSelectors>]
  def class_under_test
    Checkoff::ProjectSelectors
  end

  # @return [void]
  def respond_like_instance_of
    {
      config: Hash,
      workspaces: Checkoff::Workspaces,
      projects: Checkoff::Projects,
      custom_fields: Checkoff::CustomFields,
      portfolios: Checkoff::Portfolios,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  # @return [void]
  def respond_like
    {}
  end
end
