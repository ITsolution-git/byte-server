require 'rails_helper'

RSpec.describe UserPoint, :type => :model do
  describe 'associations' do
    it { is_expected.to belong_to(:location) }
  end

  it 'has a valid factory' do
    expect(build :state).to be_valid
  end

  describe 'allow mass assignment of' do
    it { is_expected.to allow_mass_assignment_of(:id) }
    it { is_expected.to allow_mass_assignment_of(:user_id) }
    it { is_expected.to allow_mass_assignment_of(:point_type) }
    it { is_expected.to allow_mass_assignment_of(:location_id) }
    xit { is_expected.to allow_mass_assignment_of(:created_at) }
    it { is_expected.to allow_mass_assignment_of(:points) }
    it { is_expected.to allow_mass_assignment_of(:status) }
    it { is_expected.to allow_mass_assignment_of(:is_give) }
  end
end
