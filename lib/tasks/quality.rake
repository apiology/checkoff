# frozen_string_literal: true

require 'quality/rake/task'

Quality::Rake::Task.new do |task|
  task.skip_tools = ['reek']
  task.output_dir = 'metrics'
  task.exclude_files = ['docs/example_project.png']
end
