require 'rails_helper'

xdescribe MenuItemsController do
  login_user
  describe '#batch_delete' do
    it 'deletes the categories based on the ids provided' do
      first_item = create(:test_item)
      second_item = create(:test_item)
      expect(first_item).to be
      expect(second_item).to be
      delete :batch_delete, items_to_delete: [first_item.id, second_item.id]
      expect{first_item.reload}.to raise_error
      expect{second_item.reload}.to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
