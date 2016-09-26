require 'rails_helper'

describe Checkin do

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:location_id) }
    it { should allow_mass_assignment_of(:user_id) }
  end

  # Associations
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:location) }
  end

  # method
  describe 'Method' do

    context ".format_checkins" do
      xit "checkin should be blank" do
        Checkin.format_checkins([]).should eq(nil)
      end
    end
  end
end
