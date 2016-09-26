class PrizeRedeem < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :prize_id, :user_id, :share_prize_id, :from_user, :type, :level,
    :from_redeem, :redeem_value, :is_redeem, :timezone


  #############################
  ###  ASSOCIATIONS
  #############################
  belongs_to :prize
  belongs_to :user


  #############################
  ###  VALIDATIONS
  #############################
  validates :prize_id, presence: true, numericality: { only_integer: true }
  validates :user_id, presence: true, numericality: { only_integer: true }
  validates :from_user, allow_nil: true, numericality: { only_integer: true }
  validates :share_prize_id, allow_nil: true, numericality: { only_integer: true }

end