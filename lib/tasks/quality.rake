# frozen_string_literal: true

require 'time'  # TODO: Fix - https://app.circleci.com/pipelines/github/apiology/checkoff/33/workflows/480beafa-dcb6-4286-bd5b-a7d80c51dd57/jobs/112
require 'quality/rake/task'

Quality::Rake::Task.new do |task|
  task.skip_tools = %w[reek cane eslint jscs pycodestyle rails_best_practices flake8]
  task.output_dir = 'metrics'
  task.exclude_files = ['docs/example_project.png', '.rubocop.yml']
end
