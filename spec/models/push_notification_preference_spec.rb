require 'rails_helper'

describe PushNotificationPreference, :type => :model do

  before :each do
    mock_geocoding!
    @user = create(:create_user)
  end

  describe '.all_preferences_for(user)' do
    it 'should return an array' do
      # Every preference should be true
      preferences = {}
      PUSH_NOTIFICATION_TYPES.each {|type| preferences[type] = true}
      expect( PushNotificationPreference.all_preferences_for(@user) ).to eq(preferences)
    end
  end

  describe '.disabled_notification_types_for(user)' do
    it 'should return an array' do
      # Nothing should be disabled for this user
      expect( PushNotificationPreference.disabled_notification_types_for(@user) ).to eq([])
    end
  end

  describe '.enabled_notification_types_for(user)' do
    it 'should return an array' do
      # Nothing should be disabled for this user, so everything should be enabled
      expect( PushNotificationPreference.enabled_notification_types_for(@user) ).to eq(PUSH_NOTIFICATION_TYPES)
    end
  end

  describe '.preference_action' do
    it 'should return an array' do
      expect( PushNotificationPreference.preference_action(@user, :enable, PUSH_NOTIFICATION_TYPES.first, true) ).to eq(true)
    end
  end

end
