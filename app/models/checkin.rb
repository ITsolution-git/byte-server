class Checkin < ActiveRecord::Base
  # A check-in can be created manually by a User when inside
  # a Location's geofence,
  # or automatically when a User places an order (regardless
  # of the User's current location).
  # A User must be checked in to a Location in order to submit
  # a LocationComment or an ItemComment

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :location_id, :user_id, :award_points


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location
  belongs_to :user
  has_many :item_comments
  has_one :location_comment


  #############################
  ###  VALIDATIONS
  #############################
  after_create :give_points


  #############################
  ###  VALIDATIONS
  #############################
  validates :location_id, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true, numericality: { only_integer: true }
  

  #############################
  ###  SCOPES
  #############################
  scope :location_checkin, ->(location_id) { where(location_id: location_id) }
  

  #############################
  ###  INSTANCE METHODS
  #############################

  # Are there less than MAX_COMMENTS_PER_LOCATION_CHECKIN and
  #  no other ratings for this item (referenced through build_menu) for this checkin
  def another_comment_allowed?(build_menu_id=nil, rating=nil)
    if build_menu_id.present? && rating.present? && rating.to_f > 0.0
      another_comment_allowed? && item_comments
                                    .where(build_menu_id: build_menu_id)
                                    .where("item_comments.rating > 0.0")
                                    .count.zero?
    else
      total_comment_count < MAX_COMMENTS_PER_LOCATION_CHECKIN
    end
  end

  def give_points
    if self.award_points
      UserPoint.create(
        user_id: user.id,
        location_id: location_id,
        point_type: POINT_FROM_CHECKIN,
        points: points_for_this_location,
        status: 1,
        is_give: 1
      )
    end
  end

  # def comment_on_item(build_menu_id, rating, text, order_item_id = nil)
  #   return false unless another_comment_allowed?

  #   new_item_comment = item_comments.build(
  #     user_id: user.id,
  #     build_menu_id: build_menu_id, # TODO: This should probably be item_id
  #     rating: rating,
  #     text: text
  #   )
  #   new_item_comment.order_item_id = order_item_id if order_item_id.present?
  #   new_item_comment.save
  # end

  def points
    points_for_this_location
  end

  def points_for_this_location
    location.points_awarded_for_checkin
  end

  def still_valid?
    created_at >= CHECKINS_VALID_FOR_HOURS.hours.ago
  end

  def total_comment_count
    item_comments.count + (location_comment.present? ? 1 : 0)
  end
  

  #############################
  ###  CLASS METHODS
  #############################
  def self.recent_checkin_locations_for(user)
    recent_checkin_locations = []
    recent_checkins.where(user_id: user.id).each do |checkin|
      recent_checkin_locations << checkin.location
    end
    return recent_checkin_locations.uniq
  end

  def self.recent_checkins
    where('created_at > ?', CHECKINS_VALID_FOR_HOURS.hours.ago)
  end

  def self.user_is_checked_in_at_location?(user, location)
    users_current_checkin_at_location(user, location).present?
  end

  def self.users_current_checkin_at_location(user, location)
    recent_checkins.where(user_id: user.id, location_id: location.id).order(:created_at).last
  end

end
