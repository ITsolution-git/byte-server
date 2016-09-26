require 'rails_helper'

describe ServersController do
  login_user
  xdescribe '#batch_delete' do
    it 'deletes the specified menus' do
      first_server = create(:server)
      second_server = create(:server)
      expect(first_server).to be
      expect(second_server).to be
      delete :batch_delete, items_to_delete: [first_server.id, second_server.id]
      expect{first_server.reload}.to raise_error
      expect{second_server.reload}.to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
