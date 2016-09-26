FactoryGirl.define do
  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    sequence(:email) { |n| "test#{n}@example.com" }
    password 'password1'
    username Faker::Lorem.characters(10)
    zip Faker::Number.number(5)

    trait :admin do
      role ADMIN_ROLE
    end

    trait :confirmed do
      sign_in_count 2
    end
  end

  factory :create_user, class: User do
    email 'mike.little@mymenu.us'
    password '123456'
    first_name 'Mike'
    last_name 'Little'
    role 'admin'
    email_profile 'mike.little@mymenu.us'
    app_service_id 1
    username 'MikeLittle'
    zip 12345
    authentication_token "fbZehaoWUX7ludsprgLWRw"
  end

  factory "test_user", class: User do
    to_create {|instance| instance.save(validate: false) }
    agree "agree"
    autofill "autofill"
    credit_card_number "credit_card_number"
    credit_card_expiration_date "12/08/2023"
    credit_card_cvv "123"
    billing_address "test"
    billing_country "india"
    billing_state "karnataka"
    billing_city "banglore"
    billing_zip "123456"
    billing_country_code "IN"
    credit_card_type "master"
    login "test"
    email_confirmation "test@mailinator.com"
    password_bak "!@QWE"
    full_name "test"
    restaurant_manager "test"
    skip_zip_validation true
    skip_username_validation true
    skip_first_name_validation true
    skip_last_name_validation true
    credit_card_holder_name "test test"
  end

  factory :new_user, class: User do
    username 'test_user'
    email 'test@user.com'
    password 'password'
    first_name 'Test'
    last_name 'User'
    zip '11111'
  end
end
