require 'rails_helper'

describe ComboItemItem do

  # allow mass assignment of
  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:combo_item_id) }
    it { should allow_mass_assignment_of(:item_id) }
  end

  # Associations
  describe "Associations" do
    it { should belong_to(:item) }
    it { should belong_to(:combo_item)}
  end
end
