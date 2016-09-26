# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location_date_with_day_one, class: LocationDate do
    time_from "11:20 AM"
    time_to "11:20 PM"
    day "Monday"
  end
  
  factory :location_date_with_day_second, class: LocationDate do
    time_from "11:20 AM"
    time_to "11:20 PM"
    day "Monday"
  end
  
  factory :location_date_without_day, class: LocationDate do
    time_from "11:20 AM"
    time_to "11:20 PM"
    day ""
  end
end
