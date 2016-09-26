class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :bluemix_push_id
      t.references :user

      t.timestamps
    end
    add_index :devices, :user_id
  end
end
