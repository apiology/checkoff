# frozen_string_literal: true

desc 'Load up checkoff in pry'
task :console do |_t|
  puts 'Example:'
  puts
  puts '# https://www.rubydoc.info/github/Asana/ruby-asana/master'
  puts '> client = Checkoff::Clients.new.client'
  puts '# https://developers.asana.com/docs/input-output-options'
  puts '> workspace_gid = ENV.fetch("ASANA__DEFAULT_WORKSPACE_GID")'
  puts "> task = client.tasks.find_by_id('1199961990964812', options: { fields: ['dependencies'] })"
  puts
  exec 'pry -I lib -r checkoff'
end
