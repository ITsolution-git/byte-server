require 'rails_helper'

describe PushNotificationPreferencesController, :type => :controller do

  xdescribe "GET index" do
    login_user
    it "returns http success" do
      get :index, {access_token: @user.authentication_token}
      expect(response).to be_success
      expect( ActiveSupport::JSON.decode(response.body)['notifications'].class ).to eq(Array)
    end
  end

  xdescribe "GET create" do
    login_user
    it "returns http success" do
      post :create, {access_token: @user.authentication_token, preference_action: 'subscribe', ids: ['reward_received']}
      expect(response).to be_success
    end
  end

end
