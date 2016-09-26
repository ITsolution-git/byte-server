class AddBillingToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :next_billing_date, :datetime
    add_column :subscriptions, :billing_active, :boolean
    add_index :subscriptions, :next_billing_date
    add_index :subscriptions, [:billing_active, :next_billing_date]
  end
end
