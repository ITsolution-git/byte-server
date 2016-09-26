require 'rails_helper'

describe City do

  describe "allow mass assignment of" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:state_code) }
    it { should allow_mass_assignment_of(:country_code) }
  end

  describe "Associations" do
    it { should belong_to(:state).class_name('State').with_foreign_key('state_code')  }
    it { should belong_to(:country).class_name('Country').with_foreign_key('country_code')  }
  end
end
