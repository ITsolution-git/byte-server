module Api
  class BaseController < ApplicationController
    before_filter :authenticate_user

    private

    def authenticate_user
      auth_token = request.headers["Authorization"]
      return render status: 401, json: { status: :failed, error: 'No access token passed' } if auth_token.blank?

      @user = User.where(authentication_token: auth_token).first
      devise_token = params[:devise_token]
      @user.device_token = devise_token;
      @user.save
      return render status: 401, json: { status: :failed, error: 'User not found' } if @user.blank?
    end

    def current_user
      @user
    end

    def nearby_locations
      Location.all_nearby_including_unregistered(params[:latitude], params[:longitude], 5)
      #params[:radius]
    end

    # def nearby_locations
    #   radius = params[:radius].present? ? params[:radius] : 20
    #   return @_nearby_locations if @_nearby_locations.present?

    #   lat_lon = if params[:zip].present?
    #     Location.new(address: params[:zip]).geocode
    #     elsif params[:latitude].present? && params[:longitude].present?
    #       [params[:latitude].to_d, params[:longitude].to_d]
    #     else
    #       []
    #     end
    #     @_nearby_locations = Location.near(lat_lon, radius, order: :distance)
    # end
  end
end
