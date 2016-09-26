FactoryGirl.define do
  factory :banglore_city, class: City do |c|
    c.name "banglore"
    c.state_code 'BL'
    c.country_code "IN"
  end
end
