require 'rails_helper'

describe Price do
  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:plan_id) }
    it { should allow_mass_assignment_of(:app_service_id) }
  end

  # Associations
  describe "Associations" do
    it { should have_one(:user) }
    it { should belong_to(:plan) }
    it { should belong_to(:app_service) }
  end
end
