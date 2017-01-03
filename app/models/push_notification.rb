require 'fcm'
class PushNotification < ActiveRecord::Base
  # A PushNotification uses the Parse API to send a standard
  # push notification message to the mobile devices of all
  # subscribers of a given "channel."
  # Byte's channels correspond to specific application resources,
  # such as restaurant locations, menu items, and users.


  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :notification_type, :message, :additional_data
  serialize :additional_data # a hash that might include the push_notifiable_type


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :push_notifiable, polymorphic: true


  #############################
  ###  VALIDATIONS
  #############################
  validates :notification_type, presence: true, inclusion: { in: PUSH_NOTIFICATION_TYPES }
  validates :push_notifiable_type, presence: true, inclusion: { in: PUSH_NOTIFIABLE_TYPES }
  validates :push_notifiable_id, presence: true, numericality: { only_integer: true }
  validates :message, presence: true


  #############################
  ###  INSTANCE METHODS
  #############################
  def dispatch device_token
    # You can use this method with something like:
    # Item.push_notifications.create(message: 'Great new price!').dispatch
    # but the more common way is the dispatch_message_to_resource_subscribers
    # class method (see below).
    # NOTE: We are using Parse's "Advanced Targeting" because we
    # only want to send push notifications to users whose preferences
    # allow them.

    # Create the push notification object
    # data = {
    #   alert: message,
    #   pushtype: notification_type,
    #   # title: 'TBD',
    #   sound: 'chime',
    #   badge: 'Increment',
    # }
    # data.merge!(additional_data) if additional_data.present?
    # push = Parse::Push.new(data)

    # Advanced Targeting parameters
    # (See the "Sending Pushes to Queries" subsection of:
    # https://parse.com/docs/push_guide#sending-queries/REST )
    # The User must be subscribed to the given channel and accept notifications of
    # the given type, and notifications may only be sent to the User's current device.
    # query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION).
    #   eq('channels', PushNotificationSubscription.channel_name_for(push_notifiable)). # 'channels' is an array but the Parse documentation indicates it may be used this way
    #   eq('push_notification_types', notification_type) # This should work the same way as 'channels'; an array that can be used without 'include' sytax
    # push.where = query.where

    # Send the push notification to all currently-active subscriber devices
    # push.save

    # return true
    # dm2EQT55ewY:APA91bF9xk24TPxNedvAvvdqsOIxmKngzjTiIbR6AO1xNUHSB-mrEpvVA0BWllvWMTuYgj4nlTwPGk9wzBNw3wn33trzrHiNetbWcJ_PjDKDM-WhM4nThKMvnfPzbZnwD1fmdvU1JSso,
    # debugger
    data = {
      :notification => {
        :body => message,
        # :title => "TBD",
        :icon => "myicon",
        :sound => 'chime',
        # :badge => 'Increment',
        :pushtype=> notification_type,
        :click_action=> "OpenAction",
      },
      :content_available => true,
      :to=> device_token,
      :priority => 'high',
      :data=> {
        :body => message,
        :pushtype=> notification_type,
      }
    }

    # data.merge!(additional_data) if additional_data.present?
    url = URI.parse('https://fcm.googleapis.com/fcm/send')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    # data.merge!(additional_data) if additional_data.present?
    request = Net::HTTP::Post.new(url.path,
        {"Content-Type" => 'application/json',
        'Authorization' => 'key=' + Rails.application.config.fcm_public_key}
    )
    request.body = data.to_json

    response = http.request(request)

    # fcm = FCM.new(Rails.application.config.fcm_public_key)
    # data = {
    #   alert: message,
    #   pushtype: notification_type,
    #   # title: 'TBD',
    #   sound: 'chime',
    #   badge: 'Increment',
    # }
    # registration_ids=[]
    # registration_ids << device_token
    # options = {data: data, collapse_key: "updated_score"}
    # response = fcm.send(registration_ids, options)
    return response
  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.dispatch_message_to_resource_subscribers(notification_type, message, resource, additional_data_hash = {})
    # You can use this method with something like:
    # PushNotification.dispatch_message_to_resource_subscribers('fav_item_on_special', 'Great new price!', item)

    # return false unless self.resource_is_valid?(resource)

    # resource.push_notifications.create({
    #   notification_type: notification_type,
    #   message: message,
    #   additional_data: additional_data_hash
    # }).dispatch
    return false unless self.resource_is_valid?(resource)
    resource.push_notifications.create({
      notification_type: notification_type,
      message: message,
      additional_data: additional_data_hash
    }).dispatch(resource.device_token)
  end

  def self.resource_is_valid?(resource)
    PUSH_NOTIFIABLE_TYPES.include?(resource.class.to_s)
  end
end
