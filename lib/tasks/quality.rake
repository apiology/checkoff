# frozen_string_literal: true

require 'quality/rake/task'

Quality::Rake::Task.new do |task|
  task.skip_tools = %w[reek cane eslint jscs pycodestyle rails_best_practices flake8]
  task.output_dir = 'metrics'
  task.exclude_files = ['docs/example_project.png', '.rubocop.yml']
end
