require 'rails_helper'

describe Api::V2::MenuItemsController do
  before do
    mock_geocoding!
  end
  describe '#show' do
    it 'responds with the menu item' do
      item = create(:test_item)
      location = create(:location_test)
      expect(Api::V2::MenuItemSerializer)
        .to receive(:new)
      get :show, item_id: item.id, location_id: location.id
      parsed_body = JSON.parse(response.body)
    end
  end

  describe '#find by tag' do
    it 'responds with the menu items associated with the tags' do
      location = create(:location_test)
      item = create(:test_item)
      item_tag = ItemTag.new(location.id)
      allow(ItemTag)
        .to receive(:new)
        .and_return(item_tag)
      allow(item_tag)
        .to receive(:find_by_tag)
        .and_return([item])
      expect(Api::V2::MenuItemSerializer)
        .to receive(:new)
      post :find_by_tag, location_id: location.id, tags: [{name: 'test', type: 'whatever'}]
    end
  end
end
