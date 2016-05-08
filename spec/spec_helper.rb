require 'simplecov'

SimpleCov.start do
  # this dir used by TravisCI
  add_filter 'vendor'
end
SimpleCov.refuse_coverage_drop

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.order = 'random'
  config.alias_it_should_behave_like_to :has_behavior
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Monkeypatch RSpec to help us find our place
module RSpec
  module_function

  def root
    @rspec_root ||= Pathname.new(__dir__)
  end
end

# Add the exe directory, to allow testing of gem executables as if the gem is
# already installed.
exec_dir = RSpec.root.join('../exe')
ENV['PATH'] = [exec_dir, ENV['PATH']].join(File::PATH_SEPARATOR)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[RSpec.root.join('support/**/*.rb')].each { |f| require f }

def let_double(*doubles)
  doubles.each do |double_sym|
    let(double_sym) { double(double_sym.to_s) }
  end
end
