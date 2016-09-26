class DropTableCityAndCountryAndState < ActiveRecord::Migration
  def up
    # drop_table :cities
    # drop_table :states
    # drop_table :countries
    # remove_column :feedbacks, :rating
    add_column :feedbacks, :subject, :string
  end

  def down
  end
end
