class CreateTutorialVideos < ActiveRecord::Migration
  def change
    create_table :tutorial_videos do |t|
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
