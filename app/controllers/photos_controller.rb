class PhotosController < ApplicationController
  load_and_authorize_resource :photo

  def edit
    @photo = Photo.where(id: params[:id]).first
    @restaurant = Location.where(id: params[:restaurant_id]).first
  end

  def update
    @restaurant = Location.where(id: params[:restaurant_id]).first
    if @photo.update_attributes(params[:photo])
      redirect_to manage_photos_restaurant_path(@restaurant.id), notice: 'Photo Updated'
    else
      redirect_to manage_photos_restaurant_path(@restaurant.id), alert: 'Photo Not Updated, Please Try Again'
    end
  end

  def rotate
    photo_id = params[:photo].to_i
    @photo = Photo.find_by_id(photo_id)
    unless @photo.nil?
      @photo.rotate
    end
    respond_to do |format|
      format.js#html { redirect_to restaurants_path ,:notice=> 'Restaurant was deleted successfully.'}
    end
  end
end
