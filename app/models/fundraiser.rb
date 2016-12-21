class Fundraiser < ActiveRecord::Base
  attr_accessible :address, :alt_email, :city, :credit_card_expiration_date, :credit_card_number, :credit_card_security_code, :credit_card_type,  :email, :fundraiser_name, :name, :phone, :state, :status, :url, :url, :zipcode, :locations,:fundraiser_types

  has_and_belongs_to_many :locations
  has_many :fundraiser_types

  validates :name, :presence => true  
  validates :fundraiser_name, :presence => true  
  validates :email, presence: { message: "can't be blank" }

  # validates_format_of :url, :with => /^[w]{3}\.[\S]+\.[\S]+/, :allow_blank=> true
  # validates :phone,:allow_blank=> true,
  #   :format => { :with => /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/,
  #     :message => "^Invalid Phone number format. Use: (xxx) xxx-xxxx"}

  # validates_format_of :email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  # # validates_format_of :alt_email,:with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  # validates :address, :presence => true
  # validates :city, :presence => true
  # validates :state, :presence => true
  # validates :zipcode,
  #           presence: { message:"can't be blank" },
  #           numericality: { message: "is not a number" } ,
  #           length: { is: 5 }

  # validates :credit_card_type, presence: true
  # validates :credit_card_number, presence: true, numericality: { message: 'must be numbers' }
  # validates :credit_card_expiration_date,
  #           presence: true,
  #           format: { with: /^((0[1-9])|(1[0-2]))\/(\d{2})$/,
  #                     message: "^Invalid expiration date - please use the format: MM/YY"
  #                   }
  # validates :credit_card_security_code,
  #           presence: true,
  #           numericality: { message: "must be numbers" }

end
