require 'bundler/gem_tasks'
task default: :spec
Dir['lib/tasks/**/*.rake'].each { |t| load t }

desc 'Default: Run specs and check quality.'
task default: [:localtest]
