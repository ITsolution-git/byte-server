class AddTimeRequestToUser < ActiveRecord::Migration
  def change
    add_column :users, :time_request, :datetime
  end
end
