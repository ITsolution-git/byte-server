class ItemComment < ActiveRecord::Base
  # This is a comment and/or rating of a specific menu item.
  # An ItemComment may only be submitted in the context of
  # a Checkin.

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :user_id, :checkin_id, :build_menu_id, :order_item_id, :rating, :text,
    :hide_status, :is_hide_reward_by_admin


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :build_menu
  belongs_to :checkin
  belongs_to :user #, through: :checkin # TODO: Normalize the datatable by eliminating user_id
  has_one :category, through: :build_menu
  has_one :item, through: :build_menu
  has_one :location, through: :build_menu
  has_one :menu, through: :build_menu


  #############################
  ###  CALLBACKS
  #############################
  before_validation :set_checkin_id_if_necessary # TODO: Refactor this by eliminating user_id and requiring checkin_id
  after_create :award_points, if: :first_comment_for_this_checkin?
  after_create :alert_location_owner_of_negative_rating, if: :rating_is_negative?
  after_create :alert_location_owner_of_positive_rating, if: :rating_is_very_positive?
  after_create :subscribe_user_to_push_notifications, if: :rating_is_very_positive?
  after_save :save_notification


  #############################
  ###  VALIDATIONS
  #############################
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :build_menu_id, presence: true, numericality: { only_integer: true }
  validates :checkin_id, presence: true, numericality: { only_integer: true }
  validate :user_must_be_below_checkin_comment_limit


  #############################
  ###  SCOPES
  #############################
  scope :by_user, lambda { |user_id| where(:user_id => user_id) }
  scope :comments, where( "text <> ''" )
  scope :ratings, where( "rating IS NOT ?", nil )

  def self.recent(days)
    where('item_comments.created_at > ?', days)
  end


  #############################
  ###  INSTANCE METHODS
  #############################

  def alert_location_owner_of_negative_rating
    message = "A negative '#{rating}' rating has been given for '#{item.name}'"
    owner_user = location.owner
    PushNotification.dispatch_message_to_resource_subscribers('item_rating_low', message, owner_user)
  end

  def alert_location_owner_of_positive_rating
    message = "A positive rating of '#{rating}' has been given for '#{item.name}'!"
    owner_user = location.owner
    PushNotification.dispatch_message_to_resource_subscribers('rated_high_on_special', message, owner_user)
  end

  def award_points
    # NOTE: UserPoints will only create a record if location.points_awarded_for_comment is greater than zero
    UserPoint.create_for_submitting_a_grade(user, location)
  end

  def create_notify(rating, rating_grade, params, username, publish_emails)
    if rating >= rating_grade && rating_grade != 0
      Notifications.create(params)
      UserMailer.rating(username, publish_emails, rating, params[:product_comment]).deliver if publish_emails.present?
    end
  end

  def first_comment_for_this_checkin?
    # NOTE: This method should only be used by instances that have been persisted
    self.class.where(checkin_id: checkin_id).size == 1
  end

  def get_comment_count
    item_comment = ItemComment.joins(:build_menu).where("build_menus.id = ? and build_menus.active = ?", self.build_menu_id, ACTIVE)
    item_comment = item_comment.collect {|item| item.text != ''}
    return item_comment.count
  end

  def get_rating
    item_comment = ItemComment.joins(:build_menu).where("build_menus.id=? and build_menus.active = ?", self.build_menu_id, ACTIVE)

    total_ratings = 0
    item_comment.collect {|c| total_ratings += c.rating}

    average_rating = total_ratings / item_comment.count
    return average_rating
  end

  def points_awarded_for_comment
    location.points_awarded_for_comment
  end

  def rating_is_negative?
    return (%w(D F).include?(rating) ? true : false)
  end

  def rating_is_very_positive?
    return (rating == 'A' ? true : false)
  end

  def save_notification
    params = {
      from_user: self.user_id.to_i,
      to_user: location.owner.email,
      msg_type: 'single',
      msg_subject: RATING_MESSAGE,
      message: "Points added for rating item #{item.name}",
      alert_type: 'Rating',
      alert_logo: RATING_LOGO,
      location_id: location.id,
      item_id: self.build_menu.item_id,
      points: points_awarded_for_comment,
      product_comment: self.text,
      item_comment_id: self.id
    }
    notification = Notifications.where(item_comment_id: self.id, alert_type: 'Rating').first
    if notification.present?
      notification.update_attributes(params)
    else
      create_notify(self.rating.to_f, self.build_menu.menu.rating_grade.to_f,
        params, location.owner.username, self.build_menu.menu.publish_email)
    end
  end

  def set_checkin_id_if_necessary
    if checkin_id.blank?
      current_checkin = Checkin.users_current_checkin_at_location(user, location)
      self.checkin_id = current_checkin.id if current_checkin.present?
    end
  end

  def subscribe_user_to_push_notifications
    # The user that submitted this comment will receive future notifications about it
    PushNotificationSubscription.subscribe(user, item)
  end

  def user_must_be_below_checkin_comment_limit
    unless checkin.another_comment_allowed?
      errors.add(:checkin, "has reached the maximum comment limit")
    end
  end

  def date
    self.updated_at.in_time_zone(location.timezone).strftime("%d %b %Y") if location
  end

  def created
    self.created_at.in_time_zone(location.timezone).strftime("%d %b %Y %H:%M:%S:%L") if location
  end

  def updated
    self.updated_at.in_time_zone(location.timezone).strftime("%d %b %Y %H:%M:%S:%L") if location
  end

  def user_avatar
    self.user.avatar.url if self.user && self.user.avatar
  end

  def get_rating_as_letter
    grade = " "

    case rating
    when 1.0
      grade = "A+"
    when 2.0
      grade = "A"
    when 3.0
      grade = "A-"
    when 4.0
      grade = "B+"
    when 5.0
      grade = "B"
    when 6.0
      grade = "B-"
    when 7.0
      grade = "C+"
    when 8.0
      grade = "C"
    when 9.0
      grade = "C-"
    when 10.0
      grade = "D+"
    when 11.0
      grade = "D"
    when 12.0
      grade = "D-"
    when 13.0
      grade = "F"
    else
      grade = " "
    end

    return grade
  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.calculate_item_rating(item_comment)
    item_rating = 0
    if item_comment.ratings.count!=0
      item_comment.ratings.collect {|c| item_rating = item_rating + c.rating }
      item_rating = item_rating.to_f / item_comment.ratings.count
    end
    return item_rating
  end

  def self.get_points(build_menu_id)
    build_menu = BuildMenu.find(build_menu_id)
    return Item.get_real_points(build_menu)
  end

end
