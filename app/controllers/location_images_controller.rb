class LocationImagesController < ApplicationController
  def destroy
    @location_image = LocationImage.find(params[:id])
    @location = @location_image.location
    Rails.logger.warn "***IMAGE #{@location_image}"

    @check = false
    unless @location.nil? || @location_image.nil?
      owner_id = @location.owner_id
      if current_user.id.to_i == owner_id.to_i || current_user.admin?
        @check = true
      end
    end

    if @check
      @location_image.destroy;
      flash[:notice] = "Restaurant photo removed"
    end

    redirect_to edit_restaurant_path(@location.id)
  end
end
