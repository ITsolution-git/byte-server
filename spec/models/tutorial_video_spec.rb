require 'rails_helper'

RSpec.describe TutorialVideo, :type => :model do
  xdescribe 'allow mass assignment of' do
    it { is_expected.to allow_mass_assignment_of(:title) }
    it { is_expected.to allow_mass_assignment_of(:url) }
  end
end
