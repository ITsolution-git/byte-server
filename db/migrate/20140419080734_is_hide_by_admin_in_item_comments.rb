class IsHideByAdminInItemComments < ActiveRecord::Migration
  def change
  	add_column :item_comments, :is_hide_reward_by_admin, :integer,:default => 0
  end
end
