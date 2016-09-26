require 'open-uri'

class WebserviceController < ApplicationController

  def callback
    user = User.find_by_authentication_token(params[:access_token])
    location = Location.find_by_id(params[:location_id])

    if (location && user) && (location.owner_id == user.id)
      status = "success"
    else
      status = "failed"
    end

    respond_to do |format|
      format.json do
        render json:
        {
          status: status
        }.to_json
      end
    end
  end

  def find_restaurant_pics
  end

  def show_restaurant_pics
    @twitter_photos = PhotoFinder.get_twitter_pics(params[:search_string])
    @instagram_photos = PhotoFinder.get_instagram_pics(params[:search_string])
  end
end
