require 'rails_helper'

xdescribe CategoryController do
  login_user
  describe '#batch_delete' do
    it 'deletes the categories based on the ids provided' do
      first_category = create(:category_test1)
      second_category = create(:category_test2)
      expect(first_category).to be
      expect(second_category).to be
      delete :batch_delete, items_to_delete: [first_category.id, second_category.id]
      expect{first_category.reload}.to raise_error
      expect{second_category.reload}.to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
