class PushNotificationPreference < ActiveRecord::Base
  # This data model only stores disabled notification types
  # (with the assumption that if a user is not associated
  # with a certain notification_type in this data model,
  # then the user wishes to receive that notification_type).


  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :user_id, :notification_type


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :user


  #############################
  ###  VALIDATIONS
  #############################
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :notification_type, presence: true, inclusion: { in: PUSH_NOTIFICATION_TYPES }
  validates_uniqueness_of :user_id, scope: :notification_type # allow only unique user-type combinations


  #############################
  ###  CLASS METHODS
  #############################
  def self.all_preferences_for(user)
    preferences = {}
    disabled_types = self.disabled_notification_types_for(user)
    PUSH_NOTIFICATION_TYPES.each do |type|
      preferences[type] = (disabled_types.include?(type) ? false : true)
    end
    return preferences
  end

  def self.disabled_notification_types_for(user)
    where(user_id: user.id).pluck(:notification_type)
  end

  def self.enabled_notification_types_for(user)
    disabled_notification_types = self.disabled_notification_types_for(user)
    all_notification_types = PUSH_NOTIFICATION_TYPES.clone
    return all_notification_types.reject{|type| disabled_notification_types.include? type}
  end

  def self.preference_action(user, action, notification_type, skip_updating_user_settings = false)
    parameters = {user_id: user.id, notification_type: notification_type}

    # Because the data table only contains disabled notification_types,
    # 'disable' means we should add a record, and 'enable' means we
    # should make sure no record exists.
    case action
    when :disable
      create!(parameters) # Might raise ActiveRecord::RecordInvalid exception
    when :enable
      where(parameters).destroy_all
    end

    # Now we need to update this user's device data to reflect
    # this changed preferece.
    # Note: We allow this to be skipped because if multiple
    # preferences are being changed then it is wasteful
    # to update the user's settings each time.
    unless skip_updating_user_settings
      user.update_push_notification_settings!
    end

    return true
  end

end
