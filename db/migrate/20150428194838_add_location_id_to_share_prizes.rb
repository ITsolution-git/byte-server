class AddLocationIdToSharePrizes < ActiveRecord::Migration
  def change
    # In the existing code, a Location can share a prize with a user
    # (see the 'add_prize_user' method in NotificationController).
    # This isn't ideal, but refactoring will be a substantial effort,
    # so the easiest solution is to add a location_id column to
    # track which locations are sharing which prizes.
    add_column :share_prizes, :location_id, :integer, index: true
  end
end
