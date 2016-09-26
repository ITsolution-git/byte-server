class ChangeStringForSubscriptionIdToUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :subscription_id, :string
  end
  def self.down
    change_column :users, :subscription_id, :integer
  end
end

