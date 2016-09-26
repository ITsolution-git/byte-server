require 'rails_helper'

describe Api::V2::LocationTagsController, type: :request do
  let(:result) {
    { tag_categories:
        [{
          name: 'Locations',
          tag_type: 'location',
          sequence: '1',
          tags: []
         },
         {
          name: 'Cuisine Tags',
          tag_type: 'cuisine',
          sequence: '2',
          tags: []
         },
         {
          name: 'Menu Item Tags',
          tag_type: 'menu_item',
          sequence: '4',
          tags: []
         },
         {
          name: 'Menu Item Keys',
          tag_type: 'menu_item_key',
          sequence: '5',
          tags: []
         },
         {
          name: 'Area Trends',
          tag_type: 'area_trend',
          sequence: '6',
          tags: {}
         },
         {
          name: 'Price Tag',
          tag_type: 'price',
          sequence: '3',
          tags: {}
         }
        ]
    }
  }

  let(:first_location) { create :location_test, :with_menus, name: 'first_location' }
  let(:second_location) { create :location_test, :with_menus, name: 'second_location' }
  let(:third_location) { create :location_test, name: 'third_location' }

  context 'with invalid params' do
    it 'radius is blank' do
      get 'api/v2/tags', zip: '12345', latitude: '1', longitude: '2'
      expect(response.body).to eq(result.to_json)
    end

    it 'zip or lat or long are blank' do
      get 'api/v2/tags', radius: '5'
      expect(response.body).to eq(result.to_json)
      get 'api/v2/tags', radius: '5', latitude: '1'
      expect(response.body).to eq(result.to_json)
      get 'api/v2/tags', radius: '5', longitude: '1'
      expect(response.body).to eq(result.to_json)
    end
  end

  context 'with valid params' do
    before do
      mock_geocoding!
      allow(Location).to receive(:near).and_return([first_location, second_location])
    end
    it 'gets all locations within given radius' do

      result[:tag_categories][0][:tags] = [first_location.short_address,
                                          second_location.short_address]
                                          .compact.uniq

      result[:tag_categories][1][:tags] = [first_location.primary_cuisine, second_location.primary_cuisine,
                                          first_location.secondary_cuisine, second_location.secondary_cuisine]
                                          .compact.uniq
      result[:tag_categories][2][:tags] = (1..30).map { |i| "tag_#{i}"}
      result[:tag_categories][3][:tags] = (1..30).map { |i| "item_key_#{i}"}
      result[:tag_categories][4][:tags] = { first_location: 0, second_location: 0}
      result[:tag_categories][5][:tags] = { '$' => [ 'first_location', 'second_location' ] }
      get 'api/v2/tags', radius: '5', zip: '12345', latitude: '1', longitude: '2'

      expect(response.body).to eq(result.to_json)
    end
  end
end
