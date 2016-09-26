require 'rails_helper'

module Features
  module BuildMenuHelper
    def create_build_menu(item_id, menu_id, category_id)
      build_menu = BuildMenu.new
      build_menu.item_id = item_id
      build_menu.menu_id = menu_id
      build_menu.category_id = category_id
      build_menu.save
      build_menu
    end
  end
end
