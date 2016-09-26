FactoryGirl.define do
  factory :tag do
    sequence(:name) {|i| "tag_#{i}"}
  end
end
