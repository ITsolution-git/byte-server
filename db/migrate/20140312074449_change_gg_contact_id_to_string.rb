class ChangeGgContactIdToString < ActiveRecord::Migration
  def change
    change_column :user_contact_groups, :gg_contact_group_id, :string
  end
end
