class AddItemToSocialShare < ActiveRecord::Migration
  def up
    change_table :social_shares do |s|
      s.references :item, index: true
    end
  end
  def down
    change_table :social_shares do |s|
      s.remove :item_id
    end
  end
end
