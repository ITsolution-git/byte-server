class Reward < ActiveRecord::Base
  belongs_to :location
  has_many :user_rewards
  has_many :receivers, class_name: "User", foreign_key: "receiver_id", through: :user_rewards

  attr_accessible :available_from, :default_timezone, :description, :expired_until, :name, :photo, :quantity, :share_link, :stats, :timezone

  validates :name, :available_from, :expired_until, :timezone, :quantity, :description, presence: true

  mount_uploader :photo, RewardUploader
end
