# typed: true
# frozen_string_literal: true

require_relative 'test_date'
require_relative 'test_helper'
require_relative 'class_test'

# Unit test Asana-related classes
class BaseAsana < ClassTest
  include TestDate

  # asana_projects is the raw Asana::Client#projects collection proxy
  # (client.projects.find_by_workspace/find_by_id); it's distinct from the
  # `projects` method some subclasses (TestSections, TestTasks) define
  # themselves for a real Checkoff::Projects instance under test - keeping
  # separate names avoids one silently shadowing the other.
  typed_let_mock :asana_projects, Asana::ProxiedResourceClasses::Project

  typed_let_mock :my_tasks_in_workspace_gid, String
  typed_let_mock :task_a, Asana::Resources::Task
  typed_let_mock :task_b, Asana::Resources::Task
  typed_let_mock :task_c, Asana::Resources::Task
  typed_let_mock :personal_access_token, String
  typed_let_mock :project_a, Asana::Resources::Project
  typed_let_mock :project_b, Asana::Resources::Project
  typed_let_mock :project_c, Asana::Resources::Project
  typed_let_mock :a_name, String
  typed_let_mock :b_name, String
  typed_let_mock :c_name, String
  typed_let_mock :a_gid, String

  # @param extra_fields [Array<String>]
  # @return [Hash{Symbol => Object}]
  def task_options(extra_fields: [])
    {
      per_page: 100,
      options: {
        fields: (%w[completed_at dependencies due_at due_on tags
                    memberships.project.gid memberships.project.name
                    memberships.section.name name start_at start_on] + extra_fields).sort.uniq,
      },
      completed_since: '9999-12-01',
    }
  end

  # @return [Hash{Symbol => Object}]
  def task_options_with_completed
    {
      per_page: 100,
      options: {
        fields: %w[name completed_at start_at start_on due_at due_on tags
                   memberships.project.gid memberships.project.name
                   memberships.section.name dependencies].sort.uniq,
      },
    }
  end
end
