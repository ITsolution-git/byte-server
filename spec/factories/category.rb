FactoryGirl.define do
  factory :category_with_points_max_length, class: Category do
    name 'test'
    category_points 12345678901
  end
  
  factory :category_test1, class: Category do
    name 'test1'
    category_points 1234567999
  end
  
  factory :category_test2, class: Category do
    name 'test2'
    category_points 1234567890
  end
  
  factory :category_test_zero_reward, class: Category do
    name 'test_zero_reward'
    category_points 0
  end
end
