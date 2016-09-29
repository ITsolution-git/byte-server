class SharePrize < ActiveRecord::Base
  # A SharePrize is created when one User sends a prize
  # to a second User.

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :from_user, :to_user, :prize_id, :location_id, :token, :is_redeem, :status,
  :from_share, :is_refunded, :share_id, :is_limited


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :location # Optional
  belongs_to :prize
  belongs_to :sender, class_name: User, foreign_key: :from_user
  belongs_to :recipient, class_name: User, foreign_key: :to_user


  #############################
  ###  CALLBACKS
  #############################
  before_save :init
  after_create :send_push_notification_to_recipient


  #############################
  ###  VALIDATIONS
  #############################
  validates :from_user, presence: true, numericality: { only_integer: true }
  validates :to_user, presence: true, numericality: { only_integer: true }
  validates :prize_id, presence: true, numericality: { only_integer: true }
  validates :location_id, allow_nil: true, numericality: { only_integer: true }


  #############################
  ###  INSTANCE METHODS
  #############################

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless Server.where(token: random_token).exists?
    end
  end

  def init
    generate_token if token.blank?
  end

  def send_push_notification_to_recipient
    if location.present?
      message = "You have received a prize from #{location.name}"
    else
      message = "You have received a prize from #{sender.name}"
    end
    PushNotification.dispatch_message_to_resource_subscribers('prize_received', message, recipient)
  end


  #############################
  ###  CLASS METHODS
  #############################
  def self.refund_prizes
    ActiveRecord::Base.transaction do
      sql = "SELECT sp.id, sp.from_user,sp.to_user,sp.share_id, DATE_ADD(sp.created_at, INTERVAL 10 MINUTE) as created_at,
      l.timezone, p.redeem_value, p.name, l.id as location_id
      FROM share_prizes sp
      JOIN prizes p ON p.id = sp.prize_id AND sp.status = 0
      JOIN status_prizes stp on p.status_prize_id = stp.id
      JOIN locations l ON l.id = stp.location_id
      WHERE sp.is_refunded = 0 "
      share_prizes = SharePrize.find_by_sql(sql)
      unless share_prizes.empty?
        share_prizes.each do |sp|
          unless sp.timezone.nil?
            prize_created =(sp.created_at).in_time_zone("#{sp.timezone}")
            now = DateTime.now.in_time_zone("#{sp.timezone}")
            date_compare = (Time.parse(prize_created.to_s) - Time.parse(now.to_s))

            if date_compare <= 0
              if sp.share_id.to_i == 0
                UserPoint.create({
                  :user_id => sp.from_user,
                  :point_type => PRIZES_REFUNDED,
                  :location_id => sp.location_id,
                  :points => sp.redeem_value,
                  :status => 1,
                  :is_give => 1
                  })
              else
                to_user  = sp.from_user
                from_user = sp.to_user
                sp.from_user = from_user
                sp.to_user   = to_user
                sp.status    = 1
                sp.generate_token
                sp.save
              end

              to_user = User.find_by_id(sp.from_user)
              msg = "Hi #{to_user.username}, You've shared #{sp.name} to user, but he didn't register to use BYTE app, so the Prize is refunded back to you. Thanks."

              notification = Notifications.new
              notification.from_user = User.find_by_role("admin").id
              notification.to_user = to_user.email
              notification.msg_type = "single"
              notification.location_id = sp.location_id
              notification.alert_type = PRIZE_ALERT_TYPE
              notification.alert_logo = POINT_LOGO
              notification.msg_subject = PRIZE_ALERT_TYPE
              notification.message = msg
              notification.received = 1
              notification.points = sp.redeem_value
              notification.save

              # The following line dosent actually write to the db.
              # sp.update_attributes(:is_refunded => 1)

              sp.is_refunded = 1
              sp.save
            end
            end #end unless
        end #end loop
      end
    end #End transaction
  end
end
