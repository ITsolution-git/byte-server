FactoryGirl.define do
  factory :location_test, class: Location do
    name "test"
    address "test"
    city "tewst"
    state "Karnataka"
    country "India"
    slug "test--5"
    zip "12345"
    owner_id 1
    bio "dasda"
    chain_name "test"
    timezone "Asia/Calcutta"
    rsr_manager "1,"
    last_updated_by 1
    active true
    primary_cuisine "BBQ"
    secondary_cuisine "Cajun and Creole"

    trait(:with_menus) do
      after(:build) do |l|
        l.menus << FactoryGirl.create(:test_menu, :with_items)
        l.items << l.menus.first.items
      end
    end

    factory :braintree_location do
      customer_id {
        account = Braintree::MerchantAccount.create(
          :individual => {
            :first_name => Braintree::Test::MerchantAccount::Approve,
            :last_name => "Doe",
            :email => "jane@14ladders.com",
            :phone => "5553334444",
            :date_of_birth => "1981-11-19",
            :ssn => "456-45-4567",
            :address => {
              :street_address => "111 Main St",
              :locality => "Chicago",
              :region => "IL",
              :postal_code => "60622"
            }
          },
          :funding => {
            :descriptor => "Blue Ladders",
            :destination => Braintree::MerchantAccount::FundingDestination::Bank,
            :email => "funding@blueladders.com",
            :mobile_phone => "5555555555",
            :account_number => "1123581321",
            :routing_number => "071101307"
          },
          :master_merchant_account_id => Figaro.env.braintree_master_merchant_account_id,
          #:master_merchant_account_id => 'BYTE_marketplace',
          :tos_accepted => true
        )
        account.merchant_account.id
      }
    end
    after(:build) { |location|
      location.class.skip_callback(:create, :after, :create_manager_account)
    }
  end

  factory :location_attr_accessor, class: Location do
    full_address "Banglore"
    hour_of_operation "Monday"
    time_open "11:20 AM"
    time_close "11:30 PM"
    days "Monday"
  end
end

