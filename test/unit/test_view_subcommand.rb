# typed: false
# frozen_string_literal: true

require 'json'
require 'checkoff/cli'
require_relative 'class_test'

# Test the Checkoff::ViewSubcommand class used in CLI processing
class TestViewSubcommand < ClassTest
  extend Forwardable

  def_delegators(:@mocks, :sections, :tasks)

  let_mock :task

  # @return [String]
  def task_name
    'my_task'
  end

  # @return [String]
  def due_at_value
    'fake time'
  end

  # @return [void]
  def expect_task_lookup
    # @sg-ignore Unresolved call to tasks
    tasks.expects(:task).with('workspace', :project, task_name, section_name: nil).returns(task)
  end

  # @return [void]
  def stub_task_due_fields
    # @sg-ignore Unresolved call to task
    task.expects(:name).returns(task_name).at_least(0)
    # @sg-ignore Unresolved call to task
    task.expects(:due_on).returns(nil).at_least(0)
    # @sg-ignore Unresolved call to task
    task.expects(:due_at).returns(due_at_value).at_least(0)
  end

  # @return [void]
  def test_run_on_task
    view = get_test_object do
      expect_task_lookup
      stub_task_due_fields
    end

    result = JSON.parse(view.send(:run_on_task, 'workspace', :project, '', task_name))

    assert_equal(task_name, result['name'])
    assert_equal(due_at_value, result['due'])
  end

  # @return [void]
  def test_run_on_task_not_found
    view = get_test_object do
      # @sg-ignore Unresolved call to tasks
      tasks.expects(:task).with('workspace', :project, task_name, section_name: nil).returns(nil)
    end

    e = assert_raises(RuntimeError) do
      view.send(:run_on_task, 'workspace', :project, '', task_name)
    end

    assert_match(/Task not found/, e.message)
  end

  # @return [Checkoff::ViewSubcommand]
  # @sg-ignore TestViewSubcommand#create_object return type could not be inferred
  def create_object(clazz = class_under_test)
    # @sg-ignore Unresolved call to @mocks
    # @sg-ignore Too many arguments to Class#initialize
    clazz.new('workspace', :project, nil, task_name, **@mocks.to_h)
  end

  # @return [Class<Checkoff::ViewSubcommand>]
  def class_under_test
    Checkoff::ViewSubcommand
  end

  def respond_like_instance_of
    {
      config: Checkoff::Internal::EnvFallbackConfigLoader,
      projects: Checkoff::Projects,
      sections: Checkoff::Sections,
      tasks: Checkoff::Tasks,
      stderr: IO,
    }
  end

  def respond_like
    {}
  end
end
