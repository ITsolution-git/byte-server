class Device < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :parse_installation_id, :token, :operating_system


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :user
  has_many :subscriptions, through: :user


  #############################
  ###  VALIDATIONS
  #############################
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :parse_installation_id, presence: true, length: {minimum: 3}, uniqueness: true


  #############################
  ###  CALLBACKS
  #############################
  after_create :update_push_notification_settings!
  before_destroy :delete_parse_installation_record! # to ensure only a user is only associated with a single Parse Installation


  #############################
  ###  INSTANCE METHODS
  #############################
  def delete_parse_installation_record!
    # See https://github.com/adelevie/parse-ruby-client#deleting-objects
    @parse_installation.try(:parse_delete)
  end

  def owner_is?(given_user)
    user.id == given_user.id
  end

  def parse_installation
    # This gets the "Installation" object from Parse that corresponds to this Device.

    # If we've already pulled the record from the API, return it
    return @parse_installation if @parse_installation.present?

    # If there is no Parse ID on file, we can't move forward.
    return false if !parse_installation_id

    # NOTE: The instructions in the "Installations" section of the parse-ruby-client
    # gem README are not even close to being correct - do not use them.  Use
    # the instructions under the "Objects" section (and modify as appropriate):
    # https://github.com/adelevie/parse-ruby-client#objects
    @parse_installation = self.class.get_parse_installation_by_object_id(parse_installation_id)
    return @parse_installation
  end

  def set_owner_as(user)
    update_attribute(:user_id, user.id)
    reload # so the change of the user_id takes effect
    update_push_notification_settings!
  end

  def update_push_notification_settings!
    # If necessary, set the variables
    channels_array = PushNotificationSubscription.channels_array_for(user) if !channels_array
    enabled_notification_types = PushNotificationPreference.enabled_notification_types_for(user) if !enabled_notification_types

    # NOTE: We generally need to interact with parse_installation as a hash,
    # not an object as is shown in the parse gem's documentation.
    # NOTE: There may be a bug with Parse that causes the values of custom fields
    # to be erased when they are not supplied with an update request.  As such,
    # the fields below should include ALL our custom Parse fields.

    return unless parse_installation.present?

    parse_installation['channels'] = channels_array.uniq # Standard Parse field
    parse_installation['push_notification_types'] = enabled_notification_types # Custom field

    begin
      parse_installation.save
    rescue => e
      Bugsnag.notify(e.message,
        {user_id: user.id, device_id: self.id, parse_installation_id: parse_installation_id})
      raise e
    end
  end


  #############################
  ###  CLASS METHODS
  #############################
  def self.parse_installation_exists_with_object_id?(object_id)
    get_parse_installation_by_object_id(object_id).present?
  end

  def self.get_parse_installation_by_object_id(object_id)
    Parse::Query.new("_Installation").eq('objectId', object_id).get.first
  end

  def self.users_most_recently_used_device(user, excluded_device_ids = [])
    Device.where(user_id: user.id).where('id NOT IN (?)', excluded_device_ids).order(:updated_at).last
  end

end
