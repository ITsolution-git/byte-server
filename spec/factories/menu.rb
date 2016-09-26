FactoryGirl.define do
  factory :test_menu, class: Menu do
    name "test"
    publish_status 0
    publish_email ["mike.little@mymenu.us"]

    trait :with_items do
      after(:build) do |menu|
        5.times { menu.items << FactoryGirl.create(:test_item, :with_tags) }
      end
    end
    factory :first_menu do
      id 1
    end

    factory :second_menu do
      id 2
    end
  end

  factory :published_menu, class: Menu do
    trait :with_categories do
      after(:build) do |menu|
        menu.build_menus.push BuildMenu.create(item_id: Item.last.id)
        menu.build_menus.first.category = FactoryGirl.create(:category_test1)
      end
    end
    name "test"
    publish_status 2
  end

  factory :reward_points_zero_menu, class: Menu do
    name "test"
    publish_status 0
    publish_email ["mike.little@mymenu.us"]
  end
end
