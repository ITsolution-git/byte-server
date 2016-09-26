class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :token

      t.timestamps
    end
  end
end
