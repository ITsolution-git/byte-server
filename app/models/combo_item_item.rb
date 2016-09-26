class ComboItemItem < ActiveRecord::Base
  attr_accessible :combo_item_id, :item_id

  belongs_to :item
  belongs_to :combo_item
end
