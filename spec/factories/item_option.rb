FactoryGirl.define do
  factory :item_option do
    name 'Bob'
    location_id {create(:location_test).id}
  end
end
