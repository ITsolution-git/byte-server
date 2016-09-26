require 'rails_helper'
describe ItemTag do
  before do
    mock_geocoding!
    @location = create(:location_test, :with_menus)
    allow_any_instance_of(Item)
      .to receive(:has_menu_published?)
      .and_return(true)
    allow(Location)
      .to receive(:find)
      .and_return(@location)
    @item_tag = ItemTag.new(@location.id)
  end

  describe '#find_by_tag' do
    context 'name is test' do
      context 'type is category' do
        it 'returns tags with the specified name and type' do
          records = @item_tag.find_by_tag('TEST', 'category')
          expect(records.count).to eq(0)
        end
      end
      context 'type is trending' do
        it 'returns tags with the specified name and type' do
          records = @item_tag.find_by_tag('TOP 10 MENU ITEMS', 'trending')
          expect(records.count).to eq(5)
        end
      end
      context 'type is top_grade' do
        it 'returns tags with the specified name and type' do
          records = @item_tag.find_by_tag('TEST', 'top_grade')
          expect(records.count).to eq(5)
        end
      end
      context 'type is menu_item' do
        it 'returns tags with the specified name and type' do
          records = @item_tag.find_by_tag('TEST', 'menu_item')
          expect(records.count).to eq(0)
        end
      end

      context 'type is item_key' do
        it 'returns tags with the specified name and type' do
          records = @item_tag.find_by_tag('TEST', 'item_key')
          expect(records.count).to eq(0)
        end
      end
    end
  end

  describe '#category_tags' do
    it 'gets a list of all the tags of the menu items' do
      response = @item_tag.category_tags
      @location.items.each do |item|
        item.categories.each do |category|
          expect(response[:tags]).to include (category)
        end
      end
    end
  end

  describe '#trending_tags' do
    it 'gets a list of the top trending tags' do
      response = @item_tag.trending_tags
      previous = 0
      @location.items.each do |item|
        expect(item.trending_points).to be >= previous
        previous = item.trending_points
        expect(response[:tags]).to include ('TOP 10 MENU ITEMS')
      end
    end
  end

  describe '#top_grade_tags' do
    it 'gets all items with a grade over B+' do
      response = @item_tag.top_grade_tags
      @location.items.each do |item|
        if item.rating >= 9
          expect(response[:tags]).to include(item.name.upcase)
        end
      end
    end
  end

  describe '#menu_item_tags' do
    it 'gets all menu item types from the items' do
      response = @item_tag.menu_item_tags
      @location.items.each do |item|
        if item.item_type.present?
          expect(response[:tags]).to include(item.item_type.name.upcase)
        end
      end
    end
  end

  describe '#item_key_tags' do
    it 'gets all menu item keys from the items' do
      response = @item_tag.item_key_tags
      @location.items.each do |item|
        item.item_keys.each do |key|
          expect(response[:tags]).to include(key.name.upcase)
        end
      end
    end
  end

end
