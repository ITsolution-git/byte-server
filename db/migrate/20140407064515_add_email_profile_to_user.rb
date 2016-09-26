class AddEmailProfileToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_profile, :string
  end
end
