module Admin
  class SuspendAccountsController < ApplicationController
    def update
      user = User.where(id: params[:user_id]).first
      if user.present? && user.update_attribute(:is_suspended, !user.is_suspended?)
        flash[:success] = 'Account Status was successfully changed'
      else
        flash[:error] = 'Account Status was not changed due to errors'
      end
      redirect_to search_user_accounts_url
    end
  end
end
