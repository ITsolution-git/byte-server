require 'rails_helper'

xdescribe ItemOptionController do
  login_user
  describe '#batch_delete' do
    it 'deletes the specified menus' do
      first_item_option = create(:item_option)
      second_item_option = create(:item_option)
      expect(first_item_option).to be
      expect(second_item_option).to be
      delete :batch_delete, items_to_delete: [first_item_option.id, second_item_option.id]
      expect{first_item_option.reload}.to raise_error
      expect{second_item_option.reload}.to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
