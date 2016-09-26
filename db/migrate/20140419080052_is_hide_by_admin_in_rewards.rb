class IsHideByAdminInRewards < ActiveRecord::Migration
  def change
  	add_column :notifications, :is_hide_reward_by_admin, :integer,:default => 0
  end
end
