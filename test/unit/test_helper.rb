require 'simplecov'
SimpleCov.start do
  # this dir used by TravisCI/CircleCI
  add_filter '/vendor/bundle'
end
SimpleCov.refuse_coverage_drop

require 'minitest/autorun'
require 'mocha/setup'
require 'minitest/profile'

require_relative 'cachemethoddouble'
require_relative '../../lib/checkoff'

ENV['TZ'] = 'US/Eastern'

# Module which adds helpers to run tests as if it was a specific date.
module TestDate
  attr_writer :time_period
  attr_writer :mock_date_str

  def time_period
    @time_period ||= :afternoon
  end

  def mock_date_str
    @mock_date_str ||= '2013-05-24'
  end

  def mock_date
    @mock_date ||= Date.parse(mock_date_str)
  end

  TIME_BY_PERIOD = {
    two_am: '02:00:20',
    morning_during_breakfast: '07:30:20',
    morning: '07:33:20',
    eight_thirty_am: '8:30:00',
    ten_am: '10:00:20',
    mid_morning: '10:33:20',
    eleven_thirty_am: '11:30:00',
    afternoon: '14:33:20',
    three_forty_five_pm: '15:45:20',
    four_fifteen_pm: '16:15:20',
    four_forty_five_pm: '16:45:20',
    five_forty_five_pm: '17:45:20',
    six_fifteen_pm: '18:15:00',
    six_forty_five_pm: '18:45:00',
    night: '19:00:20',
    evening: '19:01:20',
    late_evening: '21:33:20',
    late_late_evening: '22:33:20',
  }.freeze

  def time_by_period(zone)
    times = TIME_BY_PERIOD.map do |sym, time|
      [sym, Time.parse("#{mock_date_str} #{time} #{zone}")]
    end
    Hash[times]
  end

  def mock_now_with_zone(zone)
    time = time_by_period(zone)[time_period]
    raise if time.nil?
    time
  end

  def mock_now
    zone = Time.now.zone
    zone = 'US/Eastern' if %w(EST EDT).include? zone
    mock_now_with_zone(zone)
  end

  def mock_time_clazz
    time = mock('time')
    time.expects(:now).returns(mock_now).at_least(0)
    time
  end

  def mock_date_clazz
    date = mock('date')
    date.expects(:today).returns(mock_date).at_least(0)
    date
  end

  def date_time_args
    {
      time: mock_time_clazz,
      date: mock_date_clazz,
    }
  end

  def setup_is_saturday
    self.mock_date_str = '2015-05-02'
  end

  def setup_is_sunday
    self.mock_date_str = '2015-05-03'
  end

  def setup_is_monday
    self.mock_date_str = '2015-05-04'
  end

  def setup_is_tuesday
    self.mock_date_str = '2015-05-05'
  end

  def setup_is_wednesday
    self.mock_date_str = '2015-05-06'
  end

  def setup_is_thursday
    self.mock_date_str = '2015-05-07'
  end

  def setup_is_friday
    self.mock_date_str = '2015-05-08'
  end

  def setup_before_work
    setup_is_monday
    self.time_period = :morning
  end

  def setup_work_time
    setup_is_monday
    self.time_period = :afternoon
  end

  def setup_after_work
    setup_is_monday
    self.time_period = :evening
  end
end

def let_single_mock(mock_sym)
  define_method(mock_sym.to_s) do
    var = "@#{mock_sym}"
    mock = instance_variable_get(var)
    unless mock
      mock = mock(mock_sym.to_s)
      instance_variable_set var, mock
    end
    mock
  end
end

def let_mock(*mocks)
  mocks.each do |mock_sym|
    let_single_mock(mock_sym)
  end
end

def define_singleton_method_by_proc(obj, name, block)
  metaclass = class << obj; self; end
  metaclass.send(:define_method, name, block)
end

def get_initializer_mocks(clazz, skip_these_keys: [])
  parameters = clazz.instance_method(:initialize).parameters
  named_parameters = parameters.select do |name, _value|
    name == :key
  end
  mock_syms = named_parameters.map { |_name, value| value } - skip_these_keys

  # create a hash of argument name to a new mock
  Hash[*mock_syms.map { |sym| [sym, mock(sym.to_s)] }.flatten]
end
