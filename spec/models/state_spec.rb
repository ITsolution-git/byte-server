require 'rails_helper'

describe State, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:country).with_foreign_key('country_code') }
    it { is_expected.to have_many(:cities).with_foreign_key('state_code') }
  end

  it 'has a valid factory' do
    expect(build :state).to be_valid
  end

  describe 'allow mass assignment of' do
    it { is_expected.to allow_mass_assignment_of(:name) }
    it { is_expected.to allow_mass_assignment_of(:country_code) }
    it { is_expected.to allow_mass_assignment_of(:state_code) }
  end
end
