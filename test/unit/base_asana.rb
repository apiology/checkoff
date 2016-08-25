# frozen_string_literal: true
require_relative 'test_helper'
require_relative 'class_test'

# Unit test Asana-related classes
class BaseAsana < ClassTest
  include TestDate

  let_mock :client, :projects, :my_tasks_in_workspace_id,
           :my_tasks_in_workspace, :my_time, :tasks,
           :task_a, :task_b, :task_c,
           :personal_access_token,
           :project_a, :project_b, :project_c,
           :a_name, :b_name, :c_name, :a_id, :b_id, :c_id

  let_mock :a_completed_at, :b_completed_at, :section_1

  def task_options
    {
      options: {
        fields: %w(name assignee_status completed_at due_at due_on),
      },
    }
  end
end
