require 'rails_helper'

describe PushNotificationSubscription, :type => :model do
  before :each do
    mock_geocoding!
  end

  # Class methods
  describe '.channel_name_for' do
    it 'should return the correct channel name' do
      item = create(:test_item)
      expect( PushNotificationSubscription.channel_name_for(item) ).to eq("item_#{item.id}")
    end
  end

  describe '.subscribe' do
    it 'should exist' do
      expect( PushNotificationSubscription.respond_to?(:subscribe) ).to eq(true)
    end
  end

  describe '.subscription_parameters' do
    it 'should return a Hash with 3 specific keys' do
      user = create(:create_user)
      item = create(:test_item)
      params = PushNotificationSubscription.subscription_parameters(user, item)

      expect(params[:user_id]).to eq(user.id)
      expect(params[:push_notifiable_type]).to eq(item.class.to_s)
      expect(params[:push_notifiable_id]).to eq(item.id)
    end
  end

  describe '.unsubscribe' do
    it 'should exist' do
      expect( PushNotificationSubscription.respond_to?(:unsubscribe) ).to eq(true)
    end
  end
end
