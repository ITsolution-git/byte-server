class MenuCopier
  include Resque::Plugins::Status
  include Resque::Plugins::UniqueJob
  @queue = :shared_menu

  def perform
    location = Location.find(options['location_id'])
    menu = Menu.find(options['menu_id'])
    menu_location = menu.location
    location.copy_shared_menu(menu)
    menu_location.increment(:copied_menus_cnt) && menu_location.save(validate: false)
  end
end
