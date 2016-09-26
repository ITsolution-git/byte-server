class AddCommentPointToSocialPoints < ActiveRecord::Migration
  def up
    # First, create a new field in the social_points table that will
    # take on the value of the recently-created points_awarded_for_grade
    # field in the locations table.  Then delete that field in the locations
    # table.
    SocialPoint.reset_column_information
    add_column(:social_points, :comment_point, :integer, default: 0) unless SocialPoint.column_names.include?('comment_point')# Default is zero per the social_points table's standard
=begin
    execute <<-SQL
      UPDATE social_points, locations AS location
      SET social_points.comment_point = location.points_awarded_for_grade
      WHERE social_points.location_id = location.id
    SQL
=end

    #remove_column :locations, :points_awarded_for_grade


    # Unrelated to the above, add a necessary index to the social_points table
    add_index(:social_points, :location_id, unique: true) unless SocialPoint.column_names.include?('comment_point')
  end

  def down
    add_column :locations, :points_awarded_for_grade, :integer

    execute <<-SQL
      UPDATE locations AS location, social_points
      SET location.points_awarded_for_grade = social_points.comment_point
      WHERE location.id = social_points.location_id
    SQL

    remove_column :social_points, :comment_point


    # Unrelated to the above, remove the index
    remove_index :social_points, :location_id
  end
end
