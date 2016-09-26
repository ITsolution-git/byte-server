require 'rails_helper'

describe Plan do

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:name) }
  end

  # Associations
  describe "Associations" do
    it "should have many prices" do
      t = Plan.reflect_on_association(:prices)
      t.macro.should == :has_many
    end
  end
end
