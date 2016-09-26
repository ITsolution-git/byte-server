require 'rails_helper'

RSpec.describe DevicesController, :type => :controller do

  describe "POST create" do
    login_user
    xit "returns http success" do
      stub_devices_controller_with true
      post :create, {parse_installation_id: '12345', access_token: @user.authentication_token}
      expect(response).to be_success
      expect(assigns[:device].user_id).to be
    end

    xit "returns failure" do
      stub_devices_controller_with false
      post :create, {parse_installation_id: '12345', access_token: @user.authentication_token}
      expect(response).to have_http_status(:unprocessable_entity)

    end
  end

  def stub_devices_controller_with(value)
    @device = Device.create({parse_installation_id: '12345'})
    allow(@device).to receive(:save).and_return(value)
    allow(Device).to receive(:new).
      and_return(@device)
  end

end
