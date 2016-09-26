require 'rails_helper'

describe Location do

  before do
    mock_geocoding!
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:address) }
    it { should allow_mass_assignment_of(:lat) }
    it { should allow_mass_assignment_of(:long) }
    it { should allow_mass_assignment_of(:rating) }
    it { should allow_mass_assignment_of(:city) }
    it { should allow_mass_assignment_of(:state) }
    it { should allow_mass_assignment_of(:country) }
    it { should allow_mass_assignment_of(:zip) }
    it { should allow_mass_assignment_of(:phone) }
    it { should allow_mass_assignment_of(:url) }
    it { should allow_mass_assignment_of(:location_images_attributes) }
    it { should allow_mass_assignment_of(:redemption_password) }
    it { should allow_mass_assignment_of(:bio) }
    it { should allow_mass_assignment_of(:token) }
    it { should allow_mass_assignment_of(:rsr_admin) }
    it { should allow_mass_assignment_of(:rsr_manager) }
    it { should allow_mass_assignment_of(:tax) }
    it { should allow_mass_assignment_of(:time_from) }
    it { should allow_mass_assignment_of(:full_address) }
    it { should allow_mass_assignment_of(:hour_of_operation) }
    it { should allow_mass_assignment_of(:chain_name) }
    it { should allow_mass_assignment_of(:timezone) }
    it { should allow_mass_assignment_of(:created_by) }
    it { should allow_mass_assignment_of(:last_updated_by) }
    it { should allow_mass_assignment_of(:info_id) }
    it { should allow_mass_assignment_of(:twiter_url) }
    it { should allow_mass_assignment_of(:facebook_url) }
    it { should allow_mass_assignment_of(:google_url) }
    it { should allow_mass_assignment_of(:instagram_username) }
    it { should allow_mass_assignment_of(:linked_url) }
    it { should allow_mass_assignment_of(:primary_cuisine) }
    it { should allow_mass_assignment_of(:secondary_cuisine) }
    it { should allow_mass_assignment_of(:com_url) }
    it { should allow_mass_assignment_of(:location_dates) }
    it { should allow_mass_assignment_of(:location_dates_attributes) }
    it { should allow_mass_assignment_of(:time_open) }
    it { should allow_mass_assignment_of(:time_close) }
    it { should allow_mass_assignment_of(:days) }
  end

  # Associations
  describe 'Associations' do
    it { should have_many(:location_comments).dependent(:destroy) }
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:notifications).class_name('Notifications').dependent(:destroy) }
    it { should have_many(:location_images).dependent(:destroy) }
    it { should have_many(:menus).dependent(:destroy) }
    it { should have_many(:servers).dependent(:destroy) }
    it { should have_many(:location_favourites).dependent(:destroy) }
    it { should have_many(:user_points).dependent(:destroy) }
    it { should have_many(:status_prizes).dependent(:destroy) }
    it { should have_many(:group).dependent(:destroy) }
    it { should have_many(:customers_locations).class_name('CustomersLocations').dependent(:destroy) }
    it { should have_many(:build_menus).through(:menus) }
    it { should have_many(:item_keys).dependent(:destroy) }
    it { should have_many(:location_visiteds).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
    it { should have_many(:hour_operations).dependent(:destroy) }
    it { should have_many(:checkins).dependent(:destroy) }
    it { should have_many(:location_dates).dependent(:destroy) }
    it { should have_one(:location_logo).dependent(:destroy) }
    it { should belong_to(:info) }
    it { should belong_to(:owner).class_name('User') }
  end

  describe "attr_accessor" do
    before :each do
      @location_attr_accessor = build(:location_attr_accessor)
    end

    it "returns a location object" do
      @location_attr_accessor.should be_an_instance_of Location
    end

    it "returns the correct full_address" do
      pending 'FIX asup'
      @location_attr_accessor.full_address.should eql "Banglore"
    end

    it "returns the correct hour_of_operation" do
      pending 'FIX asup'
      @location_attr_accessor.hour_of_operation.should eql "Monday"
    end

    it "returns the correct time_open" do
      @location_attr_accessor.time_open.should eql "11:20 AM"
    end

    it "returns the correct time_close" do
      @location_attr_accessor.time_close.should eql "11:30 PM"
    end

    it "returns the correct days" do
      @location_attr_accessor.days.should eql "Monday"
    end
  end

  # accepts_nested_attributes_for
  describe "accepts_nested_attributes_for" do
    it { should accept_nested_attributes_for(:location_dates) }
    xit { should accept_nested_attributes_for(:location_images)}
  end

  # Validations
  describe "Validations" do
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :country }
    it { should validate_presence_of :state }
    it { should allow_value("", nil).for(:phone) }
    it { should allow_value("", nil).for(:lat) }
    it { should allow_value("", nil).for(:long) }
    it { should allow_value("", nil).for(:rating) }
    it { should allow_value("", nil).for(:zip) }
    it { should allow_value("", nil).for(:tax) }
  end

  # Method
  describe "Method" do
    let(:location_build) {Location.new}
    before(:each) do
      @location_build = Location.new
    end

    context ".type" do
      it "Location.type should be mymenu" do
        @location_build.type.should eq("mymenu")
      end

      it "Location.type should not be blank" do
        @location_build.type.should_not eq("")
      end
    end

    context ".reference" do
      it "Location.reference should be blank" do
        @location_build.reference.should eq("")
      end

      it "Location.reference should not be fill" do
        @location_build.reference.should_not eq("test")
      end
    end

    context ".type_v1" do
      it "Location.type_v1 should be byte" do
        @location_build.type_v1.should eq("byte")
      end

      it "Location.type_v1 should not be blank" do
        @location_build.type_v1.should_not eq("")
      end
    end
  end


  describe 'when calling class method' do

    describe '.active_locations' do
      it 'should return an array' do
        expect(Location.active_locations).to eq([])
      end
    end

    xdescribe '.all_nearby_including_unregistered' do
      it 'should return an array' do
        expect(Location.all_nearby_including_unregistered(DEFAULT_LATITUDE, DEFAULT_LONGITUDE).class).to eq(Array)
      end
    end

    xdescribe '.google_places_nearby_search' do
      it 'should return an array' do
        expect(Location.google_places_nearby_search(DEFAULT_LATITUDE, DEFAULT_LONGITUDE, 10).class).to eq(Array)
      end
    end

    xdescribe '.near_coordinates_with_ids' do
      it 'should return an array' do
        expect(Location.near_coordinates_with_ids(DEFAULT_LATITUDE, DEFAULT_LONGITUDE).class).to eq(Location::FriendlyIdActiveRecordRelation)
      end
    end

    xdescribe '.near_coordinates_with_name' do
      it 'should return an array' do
        expect(Location.near_coordinates_with_name(DEFAULT_LATITUDE, DEFAULT_LONGITUDE).class).to eq(Location::FriendlyIdActiveRecordRelation)
      end
    end

  end
end
