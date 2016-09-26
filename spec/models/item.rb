require 'rails_helper'

describe Item do
  before do
    mock_geocoding!
  end
  describe '#trending_points' do
    it 'sums up several things to get what trends' do
      item = create(:test_item)

      expect(item.trending_points).to eq(0)
    end
  end
end
