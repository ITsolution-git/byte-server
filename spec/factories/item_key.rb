FactoryGirl.define do
  factory :item_key do |i|
    i.description 'hi'
    sequence(:name) { |i| "item_key_#{i}"}

    after(:build) do |item_key|
      item_key.image = FactoryGirl.create(:photo)
    end
  end
end
