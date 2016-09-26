 object @menu
    node(:id){|m| m.id}
    node(:title){|m| m.name}
    node(:start){|m| m.publish_start_date}
    node(:allDay){false}
    node(:url) {|m| '/menus/menudetails?id='+m.id.to_s}