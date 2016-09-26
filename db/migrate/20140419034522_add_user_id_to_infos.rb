class AddUserIdToInfos < ActiveRecord::Migration
  def change
    add_column :users, :info_id, :integer
  end
end
