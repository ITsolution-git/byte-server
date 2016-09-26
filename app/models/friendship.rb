class Friendship < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :friend_id, :friendable_id, :token, :location_id, :point, :pending


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :friender, class_name: User, foreign_key: :friendable_id  # The issuing User
  belongs_to :friendee, class_name: User, foreign_key: :friend_id # The receiving User (often a new user)


  #############################
  ###  CALLBACKS
  #############################
  after_create :generate_token_if_necessary
  after_create :send_push_notification_to_recipient


  #############################
  ###  VALIDATIONS
  #############################
  validates :friendable_id, presence: true, numericality: { only_integer: true }
  validates :friend_id, presence: true, numericality: { only_integer: true }


  #############################
  ###  INSTANCE METHODS
  #############################
  def friendee_name
    friendee.full_name
  end

  def friender_name
    friender.full_name
  end
  
  def generate_token_if_necessary
    generate_token if token.blank?
  end
  
  def generate_token
    token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def send_push_notification_to_recipient(reminder = false)
    if reminder
      message = "You have received a friend request from #{friender_name}"
    else
      message = "Please confirm your friend request from #{friender_name}"
    end
    PushNotification.dispatch_message_to_resource_subscribers('friend_request', message, friendee)
  end


  #############################
  ###  CLASS METHODS
  #############################
  def self.all_needing_reminders
    # We are interested in pending requests that are NOT brand new, but also not too old
    where(pending: 1).where('created_at <= ? AND created_at >= ?', 1.day.ago, 3.days.ago)
  end

end
