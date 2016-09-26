class SocialPoint < ActiveRecord::Base

  #############################
  ###  ATTRIBUTES
  #############################
  attr_accessible :facebook_point, :google_plus_point, :ibecon_point, :instragram_point, 
    :location_id, :twitter_point, :comment_point


  #############################
  ###  VALIDATIONS
  #############################
  validates :location_id, presence: true, numericality: { only_integer: true } # REQUIRED
  validates :comment_point, allow_nil: true, numericality: { only_integer: true }
  validates :facebook_point, allow_nil: true, numericality: { only_integer: true }
  validates :google_plus_point, allow_nil: true, numericality: { only_integer: true }
  validates :ibecon_point, allow_nil: true, numericality: { only_integer: true }
  validates :instragram_point, allow_nil: true, numericality: { only_integer: true }
  validates :twitter_point, allow_nil: true, numericality: { only_integer: true }

end
