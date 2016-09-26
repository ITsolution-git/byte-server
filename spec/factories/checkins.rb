FactoryGirl.define do
  factory :checkin_test, class:Checkin do |checkin|
    checkin.association :user, factory: test_user
    checkin.association :location, factory: location_test
  end
end
