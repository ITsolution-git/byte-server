require 'rails_helper'

describe Service, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  it 'has a valid factory' do
    expect(build :state).to be_valid
  end

  describe 'allow mass assignment of' do
    it { is_expected.to allow_mass_assignment_of(:provider) }
    it { is_expected.to allow_mass_assignment_of(:uemail) }
    it { is_expected.to allow_mass_assignment_of(:uid) }
    it { is_expected.to allow_mass_assignment_of(:uname) }
    it { is_expected.to allow_mass_assignment_of(:user_id) }
  end
end
