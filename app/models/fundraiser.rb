class Fundraiser < ActiveRecord::Base
  attr_accessible :address, :alt_email, :city, :credit_card_expiration_date, :credit_card_number, :credit_card_security_code, :credit_card_type, :division_image, :division_type, :email, :fundraiser_name, :name, :phone, :state, :status, :url, :url, :zipcode, :locations

  has_and_belongs_to_many :locations
end
