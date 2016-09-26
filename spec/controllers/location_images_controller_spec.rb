require 'rails_helper'

describe LocationImagesController, type: :controller do
  let!(:location_image) { create :location_image }
  login_user

  xit "deletes the image" do
    expect{
      delete :destroy, id: location_image
    }.to change(LocationImage, :count).by(-1)
  end
end
