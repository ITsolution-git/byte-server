require 'rails_helper'

describe Api::V2::TagsController do
  login_user
  before do
    mock_geocoding!
    @location = create(:location_test, :with_menus)
    allow(Location)
      .to receive(:find)
      .and_return(@location)
    @item_tag = ItemTag.new(@location.id)
  end
  describe '#show' do
    it 'gets the tags for menu_items' do
      get :show, id: @location.id
      parsed_body = JSON.parse(response.body)
      tag_kinds = @item_tag.tag_kinds
      parsed_body['tags'].each_with_index do |tag_type, index|
        expect(tag_type['tags'])
          .to match_array(tag_kinds[index][:tags])
      end
    end
  end

  def tags_from_response(response, index)
    response['tags'][index]['tags']
  end
end
