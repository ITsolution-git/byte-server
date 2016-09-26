class UserPoint < ActiveRecord::Base
  # This is for points awarded directly to a User by a restaurant Location.

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :id,
    :user_id,
    :location_id,
    :point_type,
    :points,
    :status,
    :is_give # is_give = 0 if user share point or use used point for redeemp items/ 1 if user receive point


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location
  belongs_to :user


  #############################
  ###  CALLBACKS
  #############################
  after_create :send_push_notification_to_recipient


  #############################
  ###  VALIDATIONS
  #############################
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :location_id, presence: true, numericality: { only_integer: true }
  validates :points, presence: true, numericality: { greater_than: 0 }
  validates :point_type, presence: true # TODO: Add inclusion validation here


  #############################
  ###  SCOPES
  #############################
  scope :point, where( "points IS NOT ?", nil)


  #############################
  ###  INSTANCE METHODS
  #############################

  def date
    self.created_at.strftime("%d %b %Y")
  end

  def dateformat
    self.created_at.strftime("%m.%d.%Y")
  end

  def send_push_notification_to_recipient
    if self.is_give == 1
      message = "You have received #{ActionController::Base.helpers.pluralize(points.to_i, 'point')} from #{location.name}"
      PushNotification.dispatch_message_to_resource_subscribers('points_received', message, user)
    end
  end


  #############################
  ###  CLASS METHODS
  #############################

  def self.create_for_submitting_a_grade(user, location)
    points_awarded = location.points_awarded_for_comment
    if points_awarded > 0
      create(
        user_id: user.id,
        location_id: location.id,
        points: points_awarded,
        point_type: POINT_FROM_GRADE,
        status: 1,
        is_give: 1
      )
    end
  end

  def self.has_friend(user_id, points, item, is_rate)
    # WARNING: This arbitrarily grabs the first pending friendship!
    friend = Friendship.where(friend_id: user_id, pending: 1).first

    if friend.nil?
      if @is_rate
        str_msg2 = RECEIVED_POINT_TYPE
      else
        str_msg2 = "Rate #{item['name']}"
      end

      #Add new userpoint
      UserPoint.create({
        :user_id => user_id,
        :point_type => str_msg2,
        :location_id => item['location_id'],
        :points => points,
        :status => 1,
        :is_give => 1
      })

      #Update user points
      user = User.find(user_id)
      user.update_attribute(:points,user.points+points)
      return nil
    else # there is a friend record

      if @is_rate
        str_msg = RECEIVED_POINT_TYPE
      else
        str_msg = "Rate #{item['name']}"
      end

      #Add new userpoint
      UserPoint.create({
        :user_id => user_id,
        :point_type => str_msg,
        :location_id =>item['location_id'],
        :points => points,
        :status => 1,
        :is_give => 1
      })

      #Update user points
      user = User.find(user_id)
      user.update_attribute(:points, user.points + points)

      return self.has_friend(friend.friendable_id, points.to_i, item) # TODO: Self-referential!  Get rid of this crap!
    end
  end

  def self.get_points(user_id)
    sql = "SELECT sum(CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as sum
           FROM user_points u
           JOIN locations l ON l.id = u.location_id
           WHERE u.user_id = #{user_id} AND u.status = 1"
    return self.find_by_sql(sql)
  end

  def self.get_point_contacts(user_id, location_id)
    sql = "SELECT sum(CASE WHEN u.is_give = 1 THEN u.points ELSE u.points*(-1) END) as sum
           FROM user_points u
           JOIN locations l ON l.id = u.location_id
           WHERE u.user_id = #{user_id} AND u.status = 1 AND u.location_id = #{location_id}"
    return self.find_by_sql(sql)
  end

  def self.minus_points(user_id, location_id, total_redemption)
    UserPoint.create({
      :user_id => user_id,
      :point_type => REDEMPTION,
      :location_id => location_id,
      :points => total_redemption,
      :status => 1,
      :is_give => 0 # is_give = 0 if user share point or use used point for redeemp items/ 1 if user receive point
    })
  end
end
