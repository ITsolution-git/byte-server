class UserPrize < ActiveRecord::Base
  # This is for a prize that a user receives directly from
  # a restaurant.

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :is_sent_notification, :location_id, :prize_id, :user_id


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location
  belongs_to :prize
  belongs_to :user
  has_one :status_prize, through: :prize


  #############################
  ###  CALLBACKS
  #############################
  after_create :send_push_notification_to_recipient


  #############################
  ###  INSTANCE METHODS
  #############################

  def send_push_notification_to_recipient
    message = "You have received a prize from #{location.name}"
    hash = {location_id: location.id}
    PushNotification.dispatch_message_to_resource_subscribers('prize_received', message, user, hash)
  end


  #############################
  ###  CLASS METHODS
  #############################


end
