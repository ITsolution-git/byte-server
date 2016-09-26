class CreateUserContactGroups < ActiveRecord::Migration
  def change
    create_table :user_contact_groups do |t|
      t.integer :user_id
      t.integer :contact_group_id
      t.integer :gg_contact_group_id

      t.timestamps
    end
  end
end
