# typed: false
# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'class_test'
require 'checkoff/portfolios'

class TestPortfolios < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :workspaces, :client)

  let_mock :workspace_name, :portfolio_name, :portfolio, :workspace, :workspace_gid,
           :portfolios_api, :wrong_portfolio, :wrong_portfolio_name, :users_api, :me, :me_gid,
           :portfolio_gid, :project_a

  # @return [void]
  def test_portfolio_or_raise_raises
    portfolios = get_test_object do
      # @sg-ignore Unresolved call to wrong_portfolio
      portfolio_arr = [wrong_portfolio]
      expect_portfolios_pulled(portfolio_arr)
    end
    assert_raises(RuntimeError) do
      # @sg-ignore Unresolved call to portfolio_or_raise
      portfolios.portfolio_or_raise(workspace_name, portfolio_name)
    end
  end

  # @return [void]
  def test_portfolio_or_raise
    portfolios = get_test_object do
      # @sg-ignore Unresolved call to portfolio
      # @sg-ignore Unresolved call to wrong_portfolio
      portfolio_arr = [wrong_portfolio, portfolio]
      expect_portfolios_pulled(portfolio_arr)
    end

    # @sg-ignore Unresolved call to portfolio
    # @sg-ignore Unresolved call to portfolio_or_raise
    assert_equal(portfolio, portfolios.portfolio_or_raise(workspace_name, portfolio_name))
  end

  # @return [void]
  def expect_workspace_pulled
    # @sg-ignore Unresolved call to workspaces
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
    # @sg-ignore Unresolved call to workspace
    workspace.expects(:gid).returns(workspace_gid)
  end

  # @return [void]
  def allow_portfolios_named
    # @sg-ignore Unresolved call to wrong_portfolio
    wrong_portfolio.expects(:name).returns(wrong_portfolio_name).at_least(0)
    # @sg-ignore Unresolved call to portfolio
    portfolio.expects(:name).returns(portfolio_name).at_least(0)
  end

  # @return [void]
  def expect_portfolios_api_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:portfolios).returns(portfolios_api)
  end

  # @return [void]
  def expect_me_gid_pulled
    # @sg-ignore Unresolved call to client
    client.expects(:users).returns(users_api)
    # @sg-ignore Unresolved call to users_api
    users_api.expects(:me).returns(me)
    # @sg-ignore Unresolved call to me
    me.expects(:gid).returns(me_gid)
  end

  # @return [void]
  # @param portfolio_arr [Object]
  def expect_portfolios_pulled(portfolio_arr)
    expect_workspace_pulled
    expect_portfolios_api_pulled
    expect_me_gid_pulled
    # @sg-ignore Unresolved call to portfolios_api
    portfolios_api.expects(:find_all).with(workspace: workspace_gid,
                                           owner: me_gid).returns(portfolio_arr)
    allow_portfolios_named
  end

  # @return [void]
  def test_portfolio
    portfolios = get_test_object do
      # @sg-ignore Unresolved call to portfolio
      # @sg-ignore Unresolved call to wrong_portfolio
      portfolio_arr = [wrong_portfolio, portfolio]
      expect_portfolios_pulled(portfolio_arr)
    end

    # @sg-ignore Unresolved call to portfolio
    # @sg-ignore Unresolved call to portfolio
    assert_equal(portfolio, portfolios.portfolio(workspace_name, portfolio_name))
  end

  # @return [void]
  def test_portfolio_by_gid
    portfolios = get_test_object do
      expect_portfolios_api_pulled
      # @sg-ignore Unresolved call to portfolios_api
      portfolios_api.expects(:find_by_id).with(portfolio_gid,
                                               options: { fields: ['name'] }).returns(portfolio)
    end

    # @sg-ignore Unresolved call to portfolio
    # @sg-ignore Unresolved call to portfolio_by_gid
    assert_equal(portfolio, portfolios.portfolio_by_gid(portfolio_gid))
  end

  # @return [void]
  def test_projects_in_portfolios
    portfolios = get_test_object do
      # @sg-ignore Unresolved call to @mocks
      @mocks[:projects] = Checkoff::Projects.new(client:)
      # @sg-ignore Unresolved call to portfolio
      portfolio_arr = [portfolio]
      expect_portfolios_pulled(portfolio_arr)
      # @sg-ignore Unresolved call to client
      client.expects(:portfolios).returns(portfolios_api)
      # @sg-ignore Unresolved call to portfolio
      portfolio.expects(:gid).returns(portfolio_gid)
      # @sg-ignore Unresolved call to portfolios_api
      portfolios_api.expects(:get_items_for_portfolio).with(portfolio_gid:,
                                                            options: { fields: %w[custom_fields
                                                                                  name] }).returns([project_a])
    end

    # @sg-ignore Unresolved call to project_a
    # @sg-ignore Unresolved call to projects_in_portfolio
    assert_equal([project_a], portfolios.projects_in_portfolio(workspace_name, portfolio_name))
  end

  # @return [void]
  def class_under_test
    Checkoff::Portfolios
  end

  def respond_like_instance_of
    {
      config: Hash,
      workspaces: Checkoff::Workspaces,
      projects: Checkoff::Projects,
      clients: Checkoff::Clients,
      client: Asana::Client,
    }
  end

  def respond_like
    {}
  end
end
