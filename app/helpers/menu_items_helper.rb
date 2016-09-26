module MenuItemsHelper
  def setup_item(item, location_id)
    (ItemKey.where(:location_id => location_id) - item.item_keys).uniq{|ik| ik.name}.each do |item_key|
      item.item_item_keys.build(:item_key => item_key)
    end
    (ItemOption.where(:location_id => location_id, :is_deleted => 0) - item.view_item_options).each do |item_option|
      item.item_item_options.build(:item_option => item_option)
    end
    item.item_item_keys.sort_by! {|x| x.item_key.name.downcase }.uniq {|x| x.item_key.name.downcase }
    item.item_item_options.sort_by! {|x| x.item_option.name.downcase }.uniq {|x| x.item_option.name.downcase }
    return item
  end
end
