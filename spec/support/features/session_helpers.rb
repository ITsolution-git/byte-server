module Features
  module SessionHelpers
    def sign_in(user)
      visit new_user_session_path
      fill_in 'user[login]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button I18n.t('sessions.sign_in')
    end
  end
end
