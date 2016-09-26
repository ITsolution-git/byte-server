class HourOperation < ActiveRecord::Base
  attr_accessible :day, :group_hour, :location_id, :time_close, :time_open
  belongs_to :location

  # Begin - hour of operation - New
  def self.get_hour_operation_v1(location_id)
    hours = HourOperation.where("location_id = ? and day < ?", location_id, 9).order("day ASC")
    hours = hours.sort_by{|h| [h.day, Time.parse(h[:time_open]).strftime("%H:%M")]}

    for i in (hours.length-1).downto(0)
      temp = hours[i]
      temp_open = Time.parse(temp[:time_open]).strftime("%H:%M")
      temp_close = Time.parse(temp[:time_close]).strftime("%H:%M")
      for j in (i-1).downto(0) # combines overlapping periods of time?
        if temp[:day] == hours[j][:day]
          j_close = Time.parse(hours[j][:time_close]).strftime("%H:%M")
          if temp_open <= j_close
            if temp_close <= j_close
              temp[:day] = nil
            else
              hours[j][:time_close] = temp[:time_close]
              temp[:day] = nil
            end
          end
        end
      end
    end
    hours.delete_if do |h|
      h[:day].nil?
    end
    return hours.sort_by{|h| [h.day, Time.parse(h[:time_open]).strftime("%H:%M")]}
  end

  def is_open?(loc_timezone=self.location.timezone)
    current_time = (Time.parse(DateTime.now.in_time_zone(loc_timezone).strftime("%I:%M %p")).strftime("%H:%M"))
    time_open = (Time.parse(self.time_open).strftime("%H:%M"))
    time_close = (Time.parse(self.time_close).strftime("%H:%M"))
    if within_hours(current_time, time_open, time_close) || past_midnight(current_time, time_open, time_close)
      true
    else
      false
    end
  end

  private
  def past_midnight(current_time, time_open, time_close) # evaluates true when the hours span from PM to AM time and the current time is within this period
    if time_open > time_close && (current_time >= time_open || current_time <= time_close)
      true
    else
      false
    end
  end

  def within_hours(current_time, time_open, time_close)
    if current_time >= time_open && current_time <= time_close
      true
    else
      false
    end
  end

# End - hour of operation - New
end
