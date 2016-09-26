require 'rails_helper'

describe ContactGroup do

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:title) }
  end

  # Associations
  describe "Associations" do
    it { should have_many(:location_contact_groups) }
  end
end
