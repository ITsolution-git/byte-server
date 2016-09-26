require 'rails_helper'

feature 'Manage Packages', js: true, type: :feature do
  given!(:admin) { create :user, :admin, :confirmed }

  background do
    allow_any_instance_of(User).to receive(:geocode).and_return([1,1])
    sign_in admin
  end

  xit 'add a package' do
    expect(page).to have_content I18n.t('devise.sessions.signed_in')
  end
end
