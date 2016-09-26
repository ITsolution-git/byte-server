class UserBilling < ActiveRecord::Base
  default_scope order('created_at ASC')
  attr_accessible :id, :user_id, :billing_email, :billing_password
  belongs_to :user

  validates :billing_email, presence: { message: 'can\'t be blank' }
  validates :billing_password, presence: { message: 'can\'t be blank' }
end
