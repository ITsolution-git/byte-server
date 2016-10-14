class Reward < ActiveRecord::Base
  belongs_to :location
  attr_accessible :available_from, :default_timezone, :description, :expired_until, :name, :photo, :quantity, :share_link, :stats, :timezone

  validates :name, :available_from, :expired_until, :description, presence: true

  mount_uploader :photo, RewardUploader
end
