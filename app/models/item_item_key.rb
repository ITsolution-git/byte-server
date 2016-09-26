class ItemItemKey < ActiveRecord::Base
  attr_accessible :item_id, :item_key_id, :item_key

  belongs_to :item
  belongs_to :item_key
end
