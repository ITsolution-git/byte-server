class CreatePlans < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'plans'
      create_table :plans do |t|
        t.string "name"
        t.timestamps
      end
    end  
  end
end
