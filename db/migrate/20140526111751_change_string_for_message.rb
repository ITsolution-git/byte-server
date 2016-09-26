class ChangeStringForMessage < ActiveRecord::Migration
  def up
    change_column :notifications, :message, :string, :limit => 10000
  end

  def down
  end
end
