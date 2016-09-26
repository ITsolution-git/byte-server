require 'rails_helper'

describe PushNotification do

  before :each do
    mock_geocoding!
  end
  # Mass assignments
  describe 'allow mass assignment of' do
    it 'message' do
      should allow_mass_assignment_of(:message)
    end
  end


  # Associations
  describe 'Associations' do
    it 'should belong to a push_notifiable' do
      should belong_to(:push_notifiable)
    end
  end


  # Instance methods
  describe 'dispatch' do
    it 'should should submit a push notification to the Parse API' do
      stub_request(:post, 'https://api.parse.com/1/push').to_return(status: 200)

      item = create(:test_item)
      result = item.push_notifications.create(message: 'Delicious new item!').dispatch
      expect(result).to eq(true)
    end
  end


  # Class methods

  describe '.dispatch_message_to_resource_subscribers' do
    it 'should call the dispatch instance method' do
      stub_request(:post, 'https://api.parse.com/1/push').to_return(status: 200)

      user = create(:create_user)
      result = PushNotification.dispatch_message_to_resource_subscribers('reward_received', 'You received a prize from your friend!', user)
      expect(result).to eq(true)
    end
  end

  describe '.resource_is_valid?' do
    it 'should return true if the resource is valid' do
      item = create(:test_item)
      expect( PushNotification.resource_is_valid?(item) ).to eq(true)
    end

    it 'should return false if the resource is not valid' do
      city = create(:banglore_city)
      expect( PushNotification.resource_is_valid?(city) ).to eq(false)
    end
  end

end
