# frozen_string_literal: true

desc 'Load up checkoff in pry'
task :console do |_t|
  exec 'pry -I lib -r checkoff'
end
