class ItemOptionAddon < ActiveRecord::Base
  attr_accessible :item_option_id, :name, :price, :is_selected, :is_deleted

  belongs_to :item_option
  has_many :order_item_options

  validates :name , length:{minimum: 1, message:"^Addon Name can't be blank"}
  validates :price ,:presence =>true
  default_scope :order => "id"

  def display_price_with_float_format
    self.price.to_f
  end

end
