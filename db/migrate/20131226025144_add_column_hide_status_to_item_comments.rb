class AddColumnHideStatusToItemComments < ActiveRecord::Migration
  def change
  	add_column :item_comments, :hide_status, :integer , :default => 0
  end
end
