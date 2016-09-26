module MenusHelper
  def half_array(array)
    if array.empty?
      []
    else
      array.each_slice((array.length / 2.0).ceil).to_a
    end
  end

  def setup_menu(menu, location_id)
    (Server.where(:location_id => location_id) - menu.servers).each do |server|
      menu.menu_servers.build(:server => server)
    end
    menu.menu_servers.sort_by! {|x| x.server.name}
    return menu
  end

  def share_menu_icon(menu)
    image_tag("menus/#{menu.is_shared? ? 'unshare': 'share'}_icon.png")
  end
end
