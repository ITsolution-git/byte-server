# TODO: Check if we need this

class Admin::SettingsController < ApplicationController
  def index
    @user = current_user
    @location_form = Location.new
    respond_to do |format|
      format.html
    end
  end
end
