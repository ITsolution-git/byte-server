class LocationComment < ActiveRecord::Base


  # WARNING: This class is NOT currently in use!
  # (Routes are disabled but the class remains because of
  # calls to LocationComment in the codebase that have
  # not been removed due to time constraints.)










  # This is a comment/grade/rating about a restaurant.
  # A LocationComment may only be submitted in the context of
  # a Checkin.

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :location_id, :user_id, :checkin_id, :text, :rating, :server_name, :favourite


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :checkin
  belongs_to :location
  belongs_to :user #, through: :checkin # TODO: Normalize the datatable by eliminating user_id


  #############################
  ###  CALLBACKS
  #############################
  before_validation :set_checkin_id_if_necessary # TODO: Refactor this by eliminating user_id and requiring checkin_id
  after_create :assign_points_to_user
  after_create :subscribe_user_to_push_notifications, if: :rating_is_very_positive?


  #############################
  ###  VALIDATIONS
  #############################
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :location_id, presence: true, numericality: { only_integer: true }
  validate :user_must_be_below_checkin_comment_limit


  #############################
  ###  SCOPES
  #############################
  scope :comments, where( "text <> ''" )
  scope :ratings, where( "rating IS NOT ?", nil )


  #############################
  ###  METHODS
  #############################
  def assign_points_to_user
    UserPoint.create_for_submitting_a_grade(user, location)
  end

  def date
    self.created_at.in_time_zone(self.location.timezone).strftime("%d %b %Y")
  end

  def created
    self.created_at.in_time_zone(self.location.timezone).strftime("%d %b %Y %H:%M:%S:%L")
  end

  def rating_is_very_positive?
    return nil if rating.nil?
    return (rating == 'A' ? true : false)
  end

  def set_checkin_id_if_necessary
    if checkin_id.blank?
      current_checkin = Checkin.users_current_checkin_at_location(user, location)
      checkin_id = current_checkin.id if current_checkin.present?
    end
  end

  def subscribe_user_to_push_notifications
    # The user that submitted this comment will receive future notifications about it
    PushNotificationSubscription.subscribe(user, location)
  end

  def updated
    self.updated_at.in_time_zone(self.location.timezone).strftime("%d %b %Y %H:%M:%S:%L")
  end

  def user_avatar
    user.avatar.fullpath if user && user.avatar
  end

  def user_must_be_below_checkin_comment_limit
    unless checkin.another_comment_allowed?
      errors.add(:checkin, "has reached the maximum comment limit")
    end
  end

end
