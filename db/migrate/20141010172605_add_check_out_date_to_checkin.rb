class AddCheckOutDateToCheckin < ActiveRecord::Migration
  def self.up
    Checkin.reset_column_information
    unless Checkin.column_names.include?('checkout_date')
      add_column :checkins, :checkout_date, :datetime
    end
  end

  def self.down
    Checkin.reset_column_information
    if Checkin.column_names.include?('checkout_date')
      remove_column(:checkins, :checkout_date)
    end
  end
end
