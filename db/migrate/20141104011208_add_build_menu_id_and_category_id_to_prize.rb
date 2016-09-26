class AddBuildMenuIdAndCategoryIdToPrize < ActiveRecord::Migration
  def self.up
    Prize.reset_column_information
    unless Prize.column_names.include?('build_menu_id')
      add_column :prizes, :build_menu_id, :integer
    end
    unless Prize.column_names.include?('category_id')
      add_column :prizes, :category_id, :integer
    end
  end

  def self.down
    Prize.reset_column_information
    if Prize.column_names.include?('build_menu_id')
      remove_column(:prizes, :build_menu_id)
    end
    if Prize.column_names.include?('category_id')
      remove_column(:prizes, :category_id)
    end
  end
end