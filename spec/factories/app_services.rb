# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :app_service do
  end

  factory :basic_service, class: AppService do
    name 'BASIC'
    limit 0
  end

  factory :deluxe_service, class: AppService do
    name 'DELUXE'
    limit 0
  end

  factory :premium_service, class: AppService do
    name 'PREMIUM'
    limit 0
  end
end
