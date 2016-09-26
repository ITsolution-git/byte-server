require 'rails_helper'

describe Info do

  before :each do
    mock_geocoding!
  end
  # allow mass assignment of
  describe 'allow mass assignment of' do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:phone) }
    it { should allow_mass_assignment_of(:token) }
    it { should allow_mass_assignment_of(:locations_attributes) }
    it { should allow_mass_assignment_of(:user_id) }
  end

  # Associations
  describe 'Associations' do
    it { should have_many(:locations).with_foreign_key('info_id') }
    #it { should have_one(:user) }
    it { should have_one(:info_avatar).dependent(:destroy) }
  end

  # accepts_nested_attributes_for
  describe "accepts_nested_attributes_for" do
    it { should accept_nested_attributes_for(:locations) }
  end

  #Validations
  describe "Validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :phone }
    it { should validate_presence_of :email }
    it { should ensure_length_of(:name).is_at_least(3).with_message("must be between 3 and 30 characters.") }
    it { should ensure_length_of(:name).is_at_most(30).with_message("must be between 3 and 30 characters.") }
  end

  describe "methods" do
    let(:test_info) { create(:test_info) }

    context ".init" do
      it "should be return nil" do
        Info.new.init.should eq(nil)
      end

      it "with token, should be return nil" do
        Info.new(token: "DJHDGDS").init.should eq(nil)
      end

      it "without token, should be return nil" do
        create(:create_user)
        Info.new(token: "").init.should eq(nil)
      end
    end

    context ".generate_token" do
      it "should be return nil" do
        Info.new.init.should eq(nil)
      end

      it "with token, should be return nil" do
        Info.new(token: "DJHDGDS").init.should eq(nil)
      end

      it "without token, should be return nil" do
        create(:create_user)
        Info.new(token: "").init.should eq(nil)
      end
    end

    context ".image" do
      it "should be return nil" do
        Info.new.image.should eq(nil)
      end
    end
  end
end
