FactoryGirl.define do
  factory :build_menu, class: BuildMenu do |b|
    b.category_sequence 1
    b.item_sequence 1
    b.association :item, factory: :test_item
    b.association :menu, factory: :test_menu

    trait :with_award_points do
      after(:build) do |menu|
        menu.item = FactoryGirl.create(:test_item, :with_award_points)
        menu.category = FactoryGirl.create(:category_test1)
      end
    end

    trait :without_award_points do
      after(:build) do |menu|
        menu.item = FactoryGirl.create(:test_item, :without_award_points)
        menu.category = FactoryGirl.create(:category_test_zero_reward)
      end
    end

    trait :active do
      active true
    end

    trait :inactive do
      active false
    end
  end
end
