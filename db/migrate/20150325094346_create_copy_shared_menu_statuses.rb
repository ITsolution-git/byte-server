class CreateCopySharedMenuStatuses < ActiveRecord::Migration
  def change
    create_table :copy_shared_menu_statuses do |t|
      t.integer :location_id
      t.string :job_id  # UUID returned for the Resque Job
      t.string :menu_name

      t.timestamps
    end
  end
end
