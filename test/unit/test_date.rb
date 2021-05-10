# frozen_string_literal: true

# Module which adds helpers to run tests as if it was a specific date.
module TestDate
  attr_writer :time_period, :mock_date_str

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
    times.to_h
  end

  def mock_now_with_zone(zone)
    time = time_by_period(zone)[time_period]
    raise if time.nil?

    time
  end

  def mock_now
    zone = Time.now.zone
    zone = 'US/Eastern' if %w[EST EDT].include? zone
    mock_now_with_zone(zone)
  end
end
