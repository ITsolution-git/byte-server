class SharePoint < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :friendships_id, :location_id, :points


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :friendship
  belongs_to :location


  #############################
  ###  CALLBACKS
  #############################
  after_create :send_push_notification_to_recipient


  #############################
  ###  VALIDATIONS
  #############################
  validates :friendships_id, presence: true, numericality: { only_integer: true }
  validates :location_id, presence: true, numericality: { only_integer: true }
  validates :points, presence: true, numericality: { greater_than: 0 }


  #############################
  ###  INSTANCE METHODS
  #############################

  def send_push_notification_to_recipient
    message = "You have received #{ActionController::Base.helpers.pluralize(points.to_i, 'point')} for #{location.name} from #{friendship.friender_name}"
    PushNotification.dispatch_message_to_resource_subscribers('points_received', message, friendship.friendee)
  end

end
