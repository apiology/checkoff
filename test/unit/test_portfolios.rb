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

  def test_portfolio_or_raise_raises
    portfolios = get_test_object do
      portfolio_arr = [wrong_portfolio]
      expect_portfolios_pulled(portfolio_arr)
    end
    assert_raises(RuntimeError) do
      portfolios.portfolio_or_raise(workspace_name, portfolio_name)
    end
  end

  def test_portfolio_or_raise
    portfolios = get_test_object do
      portfolio_arr = [wrong_portfolio, portfolio]
      expect_portfolios_pulled(portfolio_arr)
    end

    assert_equal(portfolio, portfolios.portfolio_or_raise(workspace_name, portfolio_name))
  end

  def expect_workspace_pulled
    workspaces.expects(:workspace_or_raise).with(workspace_name).returns(workspace)
    workspace.expects(:gid).returns(workspace_gid)
  end

  def allow_portfolios_named
    wrong_portfolio.expects(:name).returns(wrong_portfolio_name).at_least(0)
    portfolio.expects(:name).returns(portfolio_name).at_least(0)
  end

  def expect_portfolios_api_pulled
    client.expects(:portfolios).returns(portfolios_api)
  end

  def expect_me_gid_pulled
    client.expects(:users).returns(users_api)
    users_api.expects(:me).returns(me)
    me.expects(:gid).returns(me_gid)
  end

  def expect_portfolios_pulled(portfolio_arr)
    expect_workspace_pulled
    expect_portfolios_api_pulled
    expect_me_gid_pulled
    portfolios_api.expects(:find_all).with(workspace: workspace_gid,
                                           owner: me_gid).returns(portfolio_arr)
    allow_portfolios_named
  end

  def test_portfolio
    portfolios = get_test_object do
      portfolio_arr = [wrong_portfolio, portfolio]
      expect_portfolios_pulled(portfolio_arr)
    end

    assert_equal(portfolio, portfolios.portfolio(workspace_name, portfolio_name))
  end

  def test_portfolio_by_gid
    portfolios = get_test_object do
      expect_portfolios_api_pulled
      portfolios_api.expects(:find_by_id).with(portfolio_gid,
                                               options: { fields: ['name'] }).returns(portfolio)
    end

    assert_equal(portfolio, portfolios.portfolio_by_gid(portfolio_gid))
  end

  def test_projects_in_portfolios
    portfolios = get_test_object do
      @mocks[:projects] = Checkoff::Projects.new(client: client)
      portfolio_arr = [portfolio]
      expect_portfolios_pulled(portfolio_arr)
      client.expects(:portfolios).returns(portfolios_api)
      portfolio.expects(:gid).returns(portfolio_gid)
      portfolios_api.expects(:get_items_for_portfolio).with(portfolio_gid: portfolio_gid,
                                                            options: { fields: %w[custom_fields
                                                                                  name] }).returns([project_a])
    end

    assert_equal([project_a], portfolios.projects_in_portfolio(workspace_name, portfolio_name))
  end

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
