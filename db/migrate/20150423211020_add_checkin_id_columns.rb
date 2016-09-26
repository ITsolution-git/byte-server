class AddCheckinIdColumns < ActiveRecord::Migration
  # This migration is part of the process of making Checkins more central
  # to this application's functions, specifically comments/grading/rating
  # functionality.

  def up
    # NOTE: The following checkin_id columns make the respective tables'
    # user_id column redundant, but in an effort to reduce the risk of
    # causing errors with this codebase, we'll leave it.
    add_column :item_comments, :checkin_id, :integer, index: true
    add_column :location_comments, :checkin_id, :integer, index: true # This makes the user_id column a bit redundant
  end

  def down
    remove_column :item_comments, :checkin_id
    remove_column :location_comments, :checkin_id
  end
end
