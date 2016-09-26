require 'rails_helper'

RSpec.describe LocationsController, type: :controller do

  # NOTE: Unable to get these specs working because of error:
  # "undefined local variable or method `login' for #<RSpec::ExampleGroups::LocationsController::GETIndex:0x007f840af3c3d0>"
  # TODO: Test suite support files need to be refactored to eliminate this error.

  # describe "GET index" do
  #   login_user
  #   it "returns http success" do
  #     get :index, {access_token: @user.authentication_token}
  #     expect(response).to be_success
  #   end
  # end

  # describe "GET normal_search" do
  #   login_user
  #   it "returns http success" do
  #     get :normal_search, {access_token: @user.authentication_token, latitude: DEFAULT_LATITUDE, longitude: DEFAULT_LONGITUDE}
  #     expect(response).to be_success
  #   end
  # end

  # describe "GET normal_search_v1" do
  #   login_user
  #   it "returns http success" do
  #     get :normal_search_v1, {access_token: @user.authentication_token, latitude: DEFAULT_LATITUDE, longitude: DEFAULT_LONGITUDE}
  #     expect(response).to be_success
  #   end
  # end

end
