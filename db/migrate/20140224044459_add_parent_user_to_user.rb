class AddParentUserToUser < ActiveRecord::Migration
  def change
    add_column :users, :parent_user_id, :integer
  end
end
