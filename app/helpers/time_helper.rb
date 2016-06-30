# frozen_string_literal: true
module TimeHelper
  def seconds_to_duration(seconds)
    return '00:00' unless seconds

    t = Time.at(seconds).utc
    str = t.strftime('%M:%S')

    # hours
    str = "#{t.strftime('%H')}:#{str}" if seconds >= 3600

    # days
    str = "#{seconds / 3600 * 24}:#{str}" if seconds >= 3600 * 24

    str
  end
end
