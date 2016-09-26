FactoryGirl.define do
  timezone = 'America/Chicago'
  factory :greater_lesser_valid_hours, class: HourOperation do |f|
    f.time_open (Time.now.in_time_zone(timezone) - 1.hour).strftime("%H:%M")
    f.time_close (Time.now.in_time_zone(timezone) - 2.hours).strftime("%H:%M")
    association :location, factory: :location_test, timezone: timezone, country: 'USA', state: 'Texas'
  end

  factory :greater_lesser_invalid_hours, class: HourOperation do |f|
    f.time_open (Time.now.in_time_zone(timezone) + 1.hour).strftime("%H:%M")
    f.time_close (Time.now.in_time_zone(timezone) - 1.hour).strftime("%H:%M")
    association :location, factory: :location_test, timezone: timezone, country: 'USA', state: 'Texas'
  end

  factory :lesser_greater_valid_hours, class: HourOperation do |f|
    f.time_open (Time.now.in_time_zone(timezone) - 1.hour).strftime("%H:%M")
    f.time_close (Time.now.in_time_zone(timezone) + 1.hours).strftime("%H:%M")
    association :location, factory: :location_test, timezone: timezone, country: 'USA', state: 'Texas'
  end

  factory :lesser_greater_invalid_hours, class: HourOperation do |f|
    f.time_open (Time.now.in_time_zone(timezone) + 1.hour).strftime("%H:%M")
    f.time_close (Time.now.in_time_zone(timezone) + 2.hours).strftime("%H:%M")
    association :location, factory: :location_test, timezone: timezone, country: 'USA', state: 'Texas'
  end
end
