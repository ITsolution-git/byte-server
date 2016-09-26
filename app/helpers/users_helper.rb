module UsersHelper
  def user_status(user)
    user.is_suspended? ? SUSPENDED_STATUS : ACTIVE_STATUS
  end
end
