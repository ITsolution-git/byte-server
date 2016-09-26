require 'rails_helper'
RSpec.configure do |c|
  c.include Features::ControllerMacros
end

describe UsersController, type: :controller do
  before :each do
    mock_geocoding!
  end
  render_views

  # Pending out temporarily. Need investigation on UsersController#login
  # and commit 645004b5

  xdescribe 'POST #login' do
    let(:user) { FactoryGirl.create(:create_user) }
    context 'with correct email and password' do
      it 'returns access_token' do
        post :login, email: user.email, password: user.password, format: :json
        expect(response.status).to eq(200)
        expect(response.body).to include('access_token')
      end
    end

    context 'with correct username and password' do
      it 'returns access_token' do
        post :login, username: user.username, password: user.password, format: :json
        expect(response.status).to eq(200)
        expect(response.body).to include('access_token')
      end
    end

    context 'with incorrect email' do
      it 'responds with 412' do
        post :login, email: 'another@email.com', password: user.password, format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'with incorrect username' do
      it 'responds with 412' do
        post :login, username: 'not_my_username', password: user.password, format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'with incorrect password' do
      it 'responds with 412' do
        post :login, email: user.email, password: 'wrong_pass', format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'with incorrect email and password' do
      it 'responds with 412' do
        post :login, email: 'another@email.com', password: 'wrong_pass', format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'with incorrect username and password' do
      it 'responds with 412' do
        post :login, username: 'not_my_username', password: 'wrong_pass', format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'without username or email' do
      it 'responds with 412' do
        post :login, password: 'wrong_pass', format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'with incorrect credentials' do
      it 'responds with 412' do
        post :login, username: 'not_my_username', email: 'another@email.com', password: 'wrong_pass', format: :json
        expect(response.status).to eq(412)
      end
    end

    context 'without credentials' do
      it 'responds with 412' do
        post :login, format: :json
        expect(response.status).to eq(412)
      end
    end
  end

  describe 'POST #register' do
    #todo: add level-up account check

    let(:new_user_attributes) { FactoryGirl.attributes_for(:new_user) }

    xcontext 'without email' do
      it 'responds with 412 and returns correct error explanation' do
        post :register, user: new_user_attributes.merge(email: ''), format: :json

        expect(response.body).to include({email: ["can't be blank"]}.to_json)
        expect(response.status).to eq(412)
      end
    end

    context 'username has already been taken' do
      xit 'responds with 412 and returns correct error explanation' do
        existing_user = FactoryGirl.create(:create_user)
        post :register, user: new_user_attributes.merge(username: existing_user.username), format: :json

        expect(response.body).to include({username: ['has already been taken']}.to_json)
        expect(response.status).to eq(412)
      end
    end

    xcontext 'without username' do
      it 'responds with 412 and returns correct error explanation' do
        post :register, user: new_user_attributes.merge(username: ''), format: :json

        expect(response.body).to include({username: ["can't be blank", "must be between 3 and 30 characters."]}.to_json)
        expect(response.status).to eq(412)
      end
    end

    xcontext 'with correct params' do
      it 'returns status: success and access_token' do
        post :register, user: new_user_attributes, format: :json

        expect(response.body).to include('access_token')
        expect(response.status).to eq(200)
      end
    end
  end
  describe '#batch_delete' do
    it 'deletes the specified users' do
      login
      first_user = create(:user)
      second_user = create(:new_user)
      expect(first_user).to be
      expect(second_user).to be
      delete :batch_delete, items_to_delete: [first_user.id, second_user.id]
      expect{first_user.reload}.to raise_error
      expect{second_user.reload}.to raise_error
      expect(response).to have_http_status(:ok)
    end
  end
end
