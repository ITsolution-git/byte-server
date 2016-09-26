class AddLocationToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :location_id, :integer
  end
end
