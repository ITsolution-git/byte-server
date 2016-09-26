class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, force: true do |t|

      t.string  :first_name
      t.string  :last_name
      t.string  :email,              :null => false, :default => ""
      t.string  :gender
      t.string  :username
      #t.string  :city
      #t.string  :address
      #t.string  :state
      t.integer :points
      t.integer :badge
      t.timestamps
    end
  end
end
