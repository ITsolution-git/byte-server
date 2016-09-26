require 'rails_helper'

RSpec.describe Admin::PricesController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Admin::Price. As you add validations to Admin::Price, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Admin::PricesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  xdescribe "GET index" do
    it "assigns all admin_prices as @admin_prices" do
      price = Price.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:admin_prices)).to eq([price])
    end
  end

  xdescribe "GET show" do
    it "assigns the requested admin_price as @admin_price" do
      price = Price.create! valid_attributes
      get :show, {:id => price.to_param}, valid_session
      expect(assigns(:admin_price)).to eq(price)
    end
  end

  xdescribe "GET new" do
    it "assigns a new admin_price as @admin_price" do
      price = Price.create! valid_attributes
      get :new, {}, valid_session
      expect(assigns(:admin_price)).to be_a_new(price)
    end
  end

  xdescribe "GET edit" do
    it "assigns the requested admin_price as @admin_price" do
      price = Price.create! valid_attributes
      get :edit, {:id => price.to_param}, valid_session
      expect(assigns(:admin_price)).to eq(price)
    end
  end

  xdescribe "POST create" do
    describe "with valid params" do
      it "creates a new Admin::Price" do
        expect {
          post :create, {:admin_price => valid_attributes}, valid_session
        }.to change(Price, :count).by(1)
      end

      it "assigns a newly created admin_price as @admin_price" do
        post :create, {:admin_price => valid_attributes}, valid_session
        expect(assigns(:admin_price)).to be_a(Price)
        expect(assigns(:admin_price)).to be_persisted
      end

      it "redirects to the created admin_price" do
        post :create, {:admin_price => valid_attributes}, valid_session
        expect(response).to redirect_to(Price.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved admin_price as @admin_price" do
        post :create, {:admin_price => invalid_attributes}, valid_session
        expect(assigns(:admin_price)).to be_a_new(Price)
      end

      it "re-renders the 'new' template" do
        post :create, {:admin_price => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  xdescribe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested admin_price" do
        price = Price.create! valid_attributes
        put :update, {:id => price.to_param, :admin_price => new_attributes}, valid_session
        price.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested admin_price as @admin_price" do
        price = Price.create! valid_attributes
        put :update, {:id => price.to_param, :admin_price => valid_attributes}, valid_session
        expect(assigns(:admin_price)).to eq(price)
      end

      it "redirects to the admin_price" do
        price = Price.create! valid_attributes
        put :update, {:id => price.to_param, :admin_price => valid_attributes}, valid_session
        expect(response).to redirect_to(price)
      end
    end

    describe "with invalid params" do
      it "assigns the admin_price as @admin_price" do
        price = Price.create! valid_attributes
        put :update, {:id => price.to_param, :admin_price => invalid_attributes}, valid_session
        expect(assigns(:admin_price)).to eq(price)
      end

      it "re-renders the 'edit' template" do
        price = Price.create! valid_attributes
        put :update, {:id => price.to_param, :admin_price => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE destroy" do
    it "destroys the requested admin_price" do
      price = Price.create! valid_attributes
      expect {
        delete :destroy, {:id => price.to_param}, valid_session
      }.to change(Price, :count).by(-1)
    end

    it "redirects to the admin_prices list" do
      price = Price.create! valid_attributes
      delete :destroy, {:id => price.to_param}, valid_session
      expect(response).to redirect_to(admin_prices_url)
    end
  end
end
