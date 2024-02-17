# frozen_string_literal: true

require_relative 'test_date'
require_relative 'test_helper'
require_relative 'class_test'

# Unit test Asana-related classes
class BaseAsana < ClassTest
  include TestDate

  let_mock :projects, :my_tasks_in_workspace_gid,
           :my_tasks_in_workspace, :my_time, :tasks,
           :task_a, :task_b, :task_c,
           :personal_access_token,
           :project_a, :project_b, :project_c,
           :a_name, :b_name, :c_name, :a_gid, :b_gid, :c_gid

  let_mock :a_completed_at, :b_completed_at, :section_one

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
