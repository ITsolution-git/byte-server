require 'rails_helper'

describe Api::V2::MenuItemSerializer do
  before do
    mock_geocoding!
  end

  describe '#menu_id' do
    it 'returns published menu_ids' do
      item = create(:test_item)
      menu = create(:published_menu)
      menu.publish_status = 2
      item.menus.push menu
      serializer = Api::V2::MenuItemSerializer.new item
      returned_menu = item.menus.select{|menu| menu.published?}.first.id
      parsed_body = JSON.parse(serializer.to_json)
      expect(parsed_body['menu_item']['menu_id']).to eq(returned_menu)
    end
  end

  describe '#category_id' do
    it 'returns the list of category ids on published menus' do
      item = create(:test_item)
      menu = create(:published_menu, :with_categories)
      menu.update_attribute('publish_status', 2)
      item.menus.push menu
      serializer = Api::V2::MenuItemSerializer.new item
      parsed_body = JSON.parse(serializer.to_json)

      expect(parsed_body['menu_item']['category_id']).to eq([menu.categories.first.id])
    end
  end
end
