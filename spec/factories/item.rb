FactoryGirl.define do
  factory :test_item, class: Item do |i|
    i.name "test"
    i.description "test"
    i.price 1.0
    i.item_images { |img| [img.association(:item_image)] }
    i.association :location, factory: :location_test
    i.rating 10

    after(:build) do |item|
      item.images << FactoryGirl.create(:photo)
      item.item_type = FactoryGirl.create(:item_type)
      3.times { item.item_keys << FactoryGirl.create(:item_key) }
    end

    trait :with_award_points do
      after(:create) do |item|
        item.location.points_awarded_for_grade = 20
      end
    end

    trait :without_award_points do
      after(:create) do |item|
        item.location.points_awarded_for_grade = 0
      end
    end

    trait :with_tags do
      after(:build) do |item|
        3.times { item.tags << FactoryGirl.create(:tag) }
      end
    end
  end
end
