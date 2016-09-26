require 'rails_helper'

xdescribe MenusController do
  login_user
  describe '#batch_delete' do
    it 'deletes the specified menus' do
      first_menu = create(:first_menu)
      second_menu = create(:second_menu)
      expect(first_menu).to be
      expect(second_menu).to be
      delete :batch_delete, items_to_delete: [first_menu.id, second_menu.id]
      # expect{first_menu.reload}.to raise_error
      expect{second_menu.reload}.to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
