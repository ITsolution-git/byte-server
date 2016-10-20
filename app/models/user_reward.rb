class UserReward < ActiveRecord::Base
  belongs_to :location
  belongs_to :reward
  belongs_to :sender, class_name: User, foreign_key: :sender_id
  belongs_to :receiver, class_name: User, foreign_key: :receiver_id

  attr_accessible :reedemed, :reward_id, :sender_id, :receiver_id, :location_id

  validates :reward_id, :sender_id, :receiver_id, :location_id, presence: true

  after_update :update_reward_stats

  after_create :send_push_notification_to_recipient

  def send_push_notification_to_recipient
    message = "You have received a reward from #{location.present? ? location.name : sender.name}"
    PushNotification.dispatch_message_to_resource_subscribers('reward_received', message, receiver)
  end

  def update_reward_stats
    value = reward.stats.nil? ? 1 : (reward.stats + 1)
    reward.update_attribute(:stats, value)
  end
end
