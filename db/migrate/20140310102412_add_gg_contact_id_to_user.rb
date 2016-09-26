class AddGgContactIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :gg_contact_id, :string
  end
end
