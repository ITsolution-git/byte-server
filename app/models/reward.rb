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

  def get_redeemed_per_week
    self.user_rewards.where("is_reedemed = true AND (updated_at BETWEEN ? AND ?)", 6.days.ago, Time.now).count
  end

  def get_total_redemeed_past_week
    self.user_rewards.where("is_reedemed = true AND (updated_at < ?)", 5.days.ago).count
  end

  def self.sending_weekly_reward_report
    self.find_in_batches(start: 0, batch_size: 1000) do |rewards|
      rewards.each { |reward| RewardReport.perform_async(reward.id) }
    end
  end
end
