class AddAwardPointsToCheckin < ActiveRecord::Migration
  def change
    add_column :checkins, :award_points, :boolean, default: true
  end
end
