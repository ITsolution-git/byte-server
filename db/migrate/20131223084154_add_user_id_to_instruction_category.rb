class AddUserIdToInstructionCategory < ActiveRecord::Migration
  def change
    add_column :instruction_categories, :user_id, :integer
  end
end
