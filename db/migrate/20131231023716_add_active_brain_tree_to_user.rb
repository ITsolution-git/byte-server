class AddActiveBrainTreeToUser < ActiveRecord::Migration
  def change
    add_column :users, :active_braintree, :boolean
  end
end
