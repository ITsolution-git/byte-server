class Info < ActiveRecord::Base
  attr_accessible :name, :phone, :token, :email, :locations_attributes, :user_id

  #has_many :users
  has_many :locations, :foreign_key => 'info_id'

  has_one :users

  has_one :avatar, class_name: 'Photo', as: :photoable
  has_one :info_avatar, dependent: :destroy
  accepts_nested_attributes_for :locations, allow_destroy: true
  validates :name, presence: { message: "can't be blank" },
                   length: { minimum: 3, maximum: 30, message: 'must be between 3 and 30 characters.' }
  validates :phone, presence: { message: "can't be blank" },
                    format: { with: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/, message: '^Invalid Phone number format. Use: (xxx) xxx-xxxx' }
  validates :email, presence: { message: "can't be blank" }

  after_initialize :init
  def init
    if self.has_attribute?(:token) && self.token.nil?
      self.generate_token
    end
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64
      break random_token unless User.where(token: random_token).exists?
    end
  end

  def image
    return self.info_avatar.image.url(:primary) if !self.info_avatar.nil?
  end
end
