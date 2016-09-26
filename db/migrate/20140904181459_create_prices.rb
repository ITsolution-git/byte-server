class CreatePrices < ActiveRecord::Migration
  def change
    if !ActiveRecord::Base.connection.table_exists? 'prices'
      create_table :prices do |t|
        t.integer "plan_id"
        t.integer "app_service_id"
        t.timestamps
      end
    end  
  end
end
