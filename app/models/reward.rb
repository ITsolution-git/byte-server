class Reward < ActiveRecord::Base
  belongs_to :location
  has_many :user_rewards
  has_many :senders, class_name: "User", foreign_key: "sender_id", through: :user_rewards
  has_many :receivers, class_name: "User", foreign_key: "receiver_id", through: :user_rewards

  attr_accessible :available_from, :default_timezone, :description, :expired_until, :name, :photo, :quantity, :share_link, :stats, :timezone, :weekly_reward_email

  validates :name, :available_from, :expired_until, :timezone, :quantity, :description, presence: true

  mount_uploader :photo, RewardUploader

  before_create :add_default_stats

  def add_default_stats
    self.stats = 0
  end

  def is_valid?
    time_valid = (Time.current > available_from) and (Time.current < expired_until)
    quota_valid = if stats.eql? 0
      true
    else
      quantity > stats
    end
    time_valid and quota_valid
  end
end
