class PushNotificationPreferencesController < ApplicationController
  # NOTE: This class is based on the instructions in the
  # "Parse Push Notifications" Google doc.

  before_filter :authenticate_user_json


  # GET /push_notification_preferences
  def index
    # Get a complete list of this user's preferences
    preferences_by_notification_type = PushNotificationPreference.all_preferences_for(authed_user)

    # Format the preference data per the instructions document
    preferences_array = []
    preferences_by_notification_type.each do |notification_type, boolean|
      preferences_array << {id: notification_type, status: (boolean == true ? 'on' : 'off')}
    end

    # Return the specially-formatted result
    return render status: :ok, json: {status: 'success', notifications: preferences_array}
  end

  # POST /push_notification_preferences
  def create
    # Validate the action
    preference_action = :enable if params['preference_action'] == 'subscribe'
    preference_action = :disable if params['preference_action'] == 'unsubscribe'
    unless preference_action.present?
      return render status: 422, json: {status: 'failed', errors: 'invalid action requested'}
    else
      # Execute the given action on each of the given notification_types
      notification_types = params['ids']
      notification_types = [notification_types] if !notification_types.is_a?(Array) # This allows for a non-array value
      notification_types.each do |notification_type|
        begin
          # Skip updating the user's push notification settings so we can do it after all the types have been processed
          PushNotificationPreference.preference_action(authed_user, preference_action, notification_type, true)
        rescue ActiveRecord::RecordInvalid => e
          return render status: 422, json: {status: 'failed', errors: e.message}
        end
      end

      # Update the User's push notifications only once, after all the preference changes
      # have been processed (to eliminate unnecessary database transactions).
      authed_user.update_push_notification_settings!

      return render status: :ok, json: {status: 'success'}
    end
  end

end
