require 'rails_helper'

describe LocationDate do

  # Constants
  describe "Constant" do
    it "Should have be this DAYSLIST constant in LocationDate" do
      LocationDate.should have_constant("DAYSLIST")
    end

    it "Should have proper imoprt file extension" do
      LocationDate::DAYSLIST.should eq([["Monday", "monday"], ["Tuesday", "tuesday"], ["Wednesday", "wednesday"], ["Thursday", "thursday"], ["Friday", "friday"], ["Saturday", "saturday"], ["Sunday", "sunday"], ["Mon - Fri", "mon_fri"], ["Sat - Sun", "sat_sun"]])
    end
  end

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:time_from) }
    it { should allow_mass_assignment_of(:time_to) }
    it { should allow_mass_assignment_of(:day) }
    it { should allow_mass_assignment_of(:location_id) }
  end

  # Associations
  describe "Associations" do
    it { should belong_to(:location) }
  end

  #method
  describe "Method" do
    before :each do
      @location_date_with_day_one = create(:location_date_with_day_one)
      @location_date_without_day = create(:location_date_without_day)
    end

    context ".delete_blank_record" do
      it "day should be Monday" do
        @location_date_with_day_one.day.should eq("Monday")
      end

      it "day should not be blank" do
        location_date_count = LocationDate.count
        @location_date_without_day
        LocationDate.count.should eq(location_date_count)
      end
    end
  end
end
