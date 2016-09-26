class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
    	t.column :user_id, :integer
    	t.column :rating, :decimal, :precision=> 2, :scale=>1
    	t.column :comment, :text
      t.timestamps
    end
  end
end
