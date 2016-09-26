require 'rails_helper'

describe Country, type: :model do

  describe 'associations' do
    it { is_expected.to have_many(:states).with_foreign_key('country_code') }
    it { is_expected.to have_many(:cities).with_foreign_key('country_code') }

    xcontext 'destroys dependent' do
      it 'states' do
      end
      it 'cities' do
      end
    end
  end

  it 'has a valid factory' do
    expect(build :country).to be_valid
  end

  describe 'allow mass assignment of' do
    it { is_expected.to allow_mass_assignment_of(:name) }
    it { is_expected.to allow_mass_assignment_of(:country_code) }
  end
end
