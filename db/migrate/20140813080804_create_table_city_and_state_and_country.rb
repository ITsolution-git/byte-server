class CreateTableCityAndStateAndCountry < ActiveRecord::Migration
  def up
    if !ActiveRecord::Base.connection.table_exists? 'cities'
      create_table :cities do |t|
        t.string :name
        t.string :state_code
        t.string :country_code
        t.integer :zip
        t.decimal :lat, :precision => 15, :scale => 6
        t.decimal :lng, :precision => 15, :scale => 6

        t.timestamps
      end
    end
    if !ActiveRecord::Base.connection.table_exists? 'states'
      create_table :states do |t|
        t.string :name
        t.string :state_code
        t.string :country_code

        t.timestamps
      end
    end
    if !ActiveRecord::Base.connection.table_exists? 'countries'
      create_table :countries do |t|
        t.string :country_code
        t.string :name

        t.timestamps
      end
    end
  end

  def down
    # drop_table :cities
    # drop_table :states
    # drop_table :countries
  end
end