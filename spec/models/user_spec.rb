require 'rails_helper'

describe User do

  before :each do
    mock_geocoding!
  end

  # Constants
  describe "Constant" do
    it "Should have be this ROLES constant in User" do
      User.should have_constant("ROLES")
    end

    it "Should have proper import file extension" do
      expect(User::ROLES).to eq([USER_ROLE, RTR_MANAGER_ROLE, RTR_ADMIN_ROLE, OWNER_ROLE, ADMIN_ROLE, CASHIER_ROLE])
    end
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:username) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:remember_me) }
    it { should allow_mass_assignment_of(:first_name) }
    it { should allow_mass_assignment_of(:customer_id) }
    it { should allow_mass_assignment_of(:last_name) }
    it { should allow_mass_assignment_of(:points) }
    it { should allow_mass_assignment_of(:city) }
    it { should allow_mass_assignment_of(:state) }
    it { should allow_mass_assignment_of(:address) }
    it { should allow_mass_assignment_of(:role) }
    it { should allow_mass_assignment_of(:phone) }
    it { should allow_mass_assignment_of(:parent_user_id) }
    it { should allow_mass_assignment_of(:gg_refresh_token) }
    it { should allow_mass_assignment_of(:app_service_id) }
    it { should allow_mass_assignment_of(:restaurants_attributes) }
    it { should allow_mass_assignment_of(:credit_card_attributes) }
    it { should allow_mass_assignment_of(:agree) }
    it { should allow_mass_assignment_of(:autofill) }
    it { should allow_mass_assignment_of(:zip) }
    it { should allow_mass_assignment_of(:gg_access_token) }
    it { should allow_mass_assignment_of(:credit_card_number) }
    it { should allow_mass_assignment_of(:credit_card_expiration_date) }
    it { should allow_mass_assignment_of(:credit_card_cvv) }
    it { should allow_mass_assignment_of(:billing_address) }
    it { should allow_mass_assignment_of(:billing_country) }
    it { should allow_mass_assignment_of(:billing_state) }
    it { should allow_mass_assignment_of(:billing_city) }
    it { should allow_mass_assignment_of(:billing_zip) }
    it { should allow_mass_assignment_of(:billing_city) }
    it { should allow_mass_assignment_of(:billing_country_code) }
    it { should allow_mass_assignment_of(:active_braintree) }
    it { should allow_mass_assignment_of(:subscription_id) }
    it { should allow_mass_assignment_of(:time_request) }
    it { should allow_mass_assignment_of(:email_confirmation) }
    it { should allow_mass_assignment_of(:password_bak) }
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:profile_attributes) }
    it { should allow_mass_assignment_of(:confirmed_at) }
    it { should allow_mass_assignment_of(:unconfirmed_email) }
    it { should allow_mass_assignment_of(:checkbox_app_service_value) }
    it { should allow_mass_assignment_of(:confirmation_token) }
    it { should allow_mass_assignment_of(:login) }
    it { should allow_mass_assignment_of(:is_register) }
    it { should allow_mass_assignment_of(:email_profile) }
    it { should allow_mass_assignment_of(:restaurant_manager) }
    it { should allow_mass_assignment_of(:token) }
    it { should allow_mass_assignment_of(:account_number) }
    it { should allow_mass_assignment_of(:is_add_friend) }
    it { should allow_mass_assignment_of(:skip_zip_validation) }
    it { should allow_mass_assignment_of(:skip_username_validation) }
    it { should allow_mass_assignment_of(:skip_first_name_validation) }
    it { should allow_mass_assignment_of(:skip_last_name_validation) }
    it { should allow_mass_assignment_of(:credit_card_holder_name) }
    it { should allow_mass_assignment_of(:token_authenticatable) }
  end

  # Associations
  describe 'Associations' do
    it { should have_many(:search_profiles).dependent(:destroy) }
    it { should have_many(:user_recent_searches).dependent(:destroy) }
    it { should have_many(:services).dependent(:destroy) }
    it { should have_many(:location_comments).dependent(:destroy) }
    it { should have_many(:item_comments).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:restaurants).dependent(:destroy).class_name('Location').with_foreign_key('owner_id') }
    it { should have_many(:item_favourites).dependent(:destroy) }
    it { should have_many(:location_favourites).dependent(:destroy) }
    it { should have_many(:server_ratings).dependent(:destroy) }
    it { should have_many(:location_favourites).dependent(:destroy) }
    it { should have_many(:location_visiteds).dependent(:destroy) }
    it { should have_many(:user_contacts) }
    it { should have_many(:contact_groups).through(:location_contact_groups) }
    it { should have_many(:sub_users).class_name('User').with_foreign_key('parent_user_id') }
    it { should have_many(:location_contact_groups).with_foreign_key('location_owner_id') }
    it { should have_one(:info) }
    it { should have_one(:profile) }
    it { should have_one(:user_avatar).dependent(:destroy) }
    it { should belong_to(:app_service) }
    it { should belong_to(:parent_user) }
    it { should belong_to(:price) }
    xit { should have_and_belong_to_many(:locations) }
  end

  describe "attr_accessor" do
    before :each do
      @user = build(:test_user)
    end

    it "returns a User object" do
      @user.should be_an_instance_of User
    end

    it "returns the correct agree" do
      @user.agree.should eql "agree"
    end

    it "returns the correct autofill" do
      @user.autofill.should eql "autofill"
    end

    it "returns the correct credit_card_number" do
      @user.credit_card_number.should eql "credit_card_number"
    end

    it "returns the correct credit_card_expiration_date" do
      @user.credit_card_expiration_date.should eql "12/08/2023"
    end

    it "returns the correct credit_card_cvv" do
      @user.credit_card_cvv.should eql "123"
    end

    it "returns the correct billing_address" do
      @user.billing_address.should eql "test"
    end

    it "returns the correct billing_country" do
      @user.billing_country.should eql "india"
    end

    it "returns the correct billing_state" do
      @user.billing_state.should eql "karnataka"
    end

    it "returns the correct billing_city" do
      @user.billing_city.should eql "banglore"
    end

    it "returns the correct billing_zip" do
      @user.billing_zip.should eql "123456"
    end

    it "returns the correct billing_country_code" do
      @user.billing_country_code.should eql "IN"
    end

    it "returns the correct credit_card_type" do
      @user.credit_card_type.should eql "master"
    end

    it "returns the correct login" do
      @user.login.should eql "test"
    end

    it "returns the correct email_confirmation" do
      @user.email_confirmation.should eql "test@mailinator.com"
    end

    it "returns the correct password_bak" do
      @user.password_bak.should eql "!@QWE"
    end

    it "returns the correct restaurant_manager" do
      @user.restaurant_manager.should eql "test"
    end

    it "returns the correct skip_zip_validation" do
      @user.skip_zip_validation.should eql true
    end

    it "returns the correct skip_username_validation" do
      @user.skip_username_validation.should eql true
    end

    it "returns the correct skip_first_name_validation" do
      @user.skip_first_name_validation.should eql true
    end

    it "returns the correct skip_last_name_validation" do
      @user.skip_last_name_validation.should eql true
    end

    it "returns the correct credit_card_holder_name" do
      @user.credit_card_holder_name.should eql "test test"
    end
  end

  describe '#get_braintree_token' do
    context 'braintree token is not set' do
      xit 'creates a token and returns it' do
        user = create(:test_user)
        old_token = user.braintree_token
        expect(user.get_braintree_token).not_to eq(old_token)
      end
    end
    context 'braintree token is set' do
      xit 'returns the token' do
        user = create(:test_user)
        old_token = user.braintree_token
        expect(user.get_braintree_token).to eq(old_token)
      end
    end
  end

  # accepts_nested_attributes_for
  describe "accepts_nested_attributes_for" do
    it { should accept_nested_attributes_for(:profile) }
    it { should accept_nested_attributes_for(:restaurants)}
  end

  # Validations
  describe "Validations" do
    it { should validate_presence_of :username }
    it { should allow_value("", nil).for(:phone) }
    #~ it { should validate_presence_of :credit_card_expiration_date }
    #~ it { should validate_presence_of :credit_card_cvv }
    #~ it { should validate_presence_of :billing_address }
    #~ it { should validate_presence_of :billing_zip }
  end
end
