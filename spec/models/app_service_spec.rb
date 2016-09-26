require 'rails_helper'

describe AppService do

  let(:app_service) { build :app_service }

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:limit) }
  end

  # Associations
  describe "Associations" do
    it "should have many users" do
      t = AppService.reflect_on_association(:users)
      t.macro.should == :has_many
    end
  end

  # Validations
  describe "Validations" do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of(:name)}
  end

  it '#limit' do
    app_service.limit = 50
    expect(app_service.limit).to eq 50
    app_service.limit = nil
    expect(app_service.limit).to eq -1
  end

  describe "limited and unlimited service" do
    before(:each) do
      @basic_unlimited = create(:basic_service)
    end

    it "unlimit? for unlimited services" do
      @basic_unlimited.unlimit?.should eq(true)
    end
  end

  describe "service plans" do
    before(:each) do
      @basic = create(:basic_service)
      @deluxe = create(:deluxe_service)
      @premium = create(:premium_service)
    end

    it "basic plan" do
      @basic.basic?.should eq(true)
    end

    it "deluxe plan" do
      @deluxe.deluxe?.should eq(true)
    end

    it "premium plan" do
      @premium.premium?.should eq(true)
    end
  end

  describe "find plan" do
    before(:each) do
      @basic = create(:basic_service)
    end

    it "find plan" do
      #AppService.find_plan(@basic.id).should eq(BraintreeRails::Plan.find("BASIC"))
    end
  end
end
