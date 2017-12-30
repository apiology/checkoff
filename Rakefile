# frozen_string_literal: true

#
# bundle exec rake release to release a new gem
#
require 'bundler/gem_tasks'

Dir['lib/tasks/**/*.rake'].each { |t| load t }

desc 'Default: Run specs and check quality.'
task default: [:localtest]
