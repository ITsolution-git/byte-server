class PushNotificationSubscription < ActiveRecord::Base
  # The push_notification_subscription table tracks the
  # resources that a given user has expressed a desire
  # to receive push notifications from.  For example,
  # if a user gives a good rating on a menu item, he
  # might be subscribed to that item.

  # NOTE: We can generally trust Parse to track subscriptions
  # for us.  This resource is only necessary because Parse
  # may occasionally lose track of a user's subscriptions
  # due to single devices being used by multiple users.
  # When one user logs in on another user's device,
  # the Byte app needs to update the device's subscriptions
  # to reflect the new user's settings , over-writing the first
  # user's settings.  We need to track users' subscriptions
  # so we can reinstate them for users as necessary.


  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :user_id, :push_notifiable_type, :push_notifiable_id


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :user
  belongs_to :push_notifiable, polymorphic: true


  #############################
  ###  VALIDATIONS
  #############################
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :push_notifiable_type, presence: true, inclusion: { in: PUSH_NOTIFIABLE_TYPES }
  validates :push_notifiable_id, presence: true, numericality: { only_integer: true }
  validates_uniqueness_of :user_id, :scope => [:push_notifiable_type, :push_notifiable_id]


  #############################
  ###  CLASS METHODS
  #############################

  def self.channel_name_for(resource)
    "#{resource.class.to_s.underscore}_#{resource.id}" # e.g. item_34354
  end

  def self.channels_array_for(user)
    channels_array = []
    where(user_id: user.id).each do |subscription|
      channels_array << self.channel_name_for(subscription.push_notifiable)
    end
    return channels_array
  end

  def self.subscribe(user, resource)
    # You can use this method with something like: 
    # PushNotificationSubscription.subscribe(current_user, location)

    subscription_parameters = self.subscription_parameters(user, resource)
    new_subscription = self.new(subscription_parameters)
    if new_subscription.save
      new_subscription.user.update_push_notification_settings!
    end
  end

  def self.subscription_parameters(user, resource)
    return {
      user_id: user.id,
      push_notifiable_type: resource.class.to_s,
      push_notifiable_id: resource.id
    }
  end

  def self.unsubscribe(user, resource)
    # You can use this method with something like: 
    # PushNotificationSubscription.unsubscribe(current_user, location)

    subscription_parameters = self.subscription_parameters(user, resource)
    matching_subscription = where(subscription_parameters).first
    if matching_subscription
      matching_subscription.destroy
      matching_subscription.user.update_push_notification_settings!
    end
  end

end
