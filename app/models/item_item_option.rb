class ItemItemOption < ActiveRecord::Base
  attr_accessible :item_id, :item_option_id, :item_option

  belongs_to :item
  belongs_to :item_option
  belongs_to :view_item_option, :foreign_key => 'item_option_id'
end