# frozen_string_literal: true
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test/unit'
  t.libs << 'lib/checkoff'
  t.test_files = FileList['test/unit/**/test*.rb']
  #  t.verbose = true
end