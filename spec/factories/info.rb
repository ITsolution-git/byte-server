FactoryGirl.define do
  factory :test_info, class: Info do |i|
    i.name 'test'
    i.phone '1234567890'
    i.email 'test@mailinator.com'
    i.info_avatar { |info| [info.association(:info_avatar)] }
  end
end
