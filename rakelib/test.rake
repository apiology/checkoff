# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  # @sg-ignore
  t.libs << 'test/unit'
  # @sg-ignore
  t.libs << 'lib/checkoff'
  # @sg-ignore
  t.test_files = FileList['test/unit/**/test*.rb']
  #  t.verbose = true
end
