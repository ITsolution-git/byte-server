require 'rails_helper'

RSpec.describe Admin::PlansController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Admin::Plan. As you add validations to Admin::Plan, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Admin::PlansController. Be sure to keep this updated too.
  let(:valid_session) {
    {"warden.user.user.key" => session["warden.user.user.key"]}
  }

  xdescribe "GET index" do
    it "assigns all admin_plans as @admin_plans" do
      plan = Plan.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:admin_plans)).to eq([plan])
    end
  end

  xdescribe "GET show" do
    it "assigns the requested admin_plan as @admin_plan" do
      plan = Plan.create! valid_attributes
      get :show, {:id => plan.to_param}, valid_session
      expect(assigns(:admin_plan)).to eq(plan)
    end
  end

  xdescribe "GET new" do
    it "assigns a new admin_plan as @admin_plan" do
      plan = Plan.create! valid_attributes
      get :new, {}, valid_session
      expect(assigns(:admin_plan)).to be_a_new(plan)
    end
  end

  xdescribe "GET edit" do
    it "assigns the requested admin_plan as @admin_plan" do
      plan = Plan.create! valid_attributes
      get :edit, {:id => plan.to_param}, valid_session
      expect(assigns(:admin_plan)).to eq(plan)
    end
  end

  xdescribe "POST create" do
    describe "with valid params" do
      it "creates a new Admin::Plan" do
        expect {
          post :create, {:admin_plan => valid_attributes}, valid_session
        }.to change(Plan, :count).by(1)
      end

      it "assigns a newly created admin_plan as @admin_plan" do
        post :create, {:admin_plan => valid_attributes}, valid_session
        expect(assigns(:admin_plan)).to be_a(Plan)
        expect(assigns(:admin_plan)).to be_persisted
      end

      it "redirects to the created admin_plan" do
        post :create, {:admin_plan => valid_attributes}, valid_session
        expect(response).to redirect_to(Plan.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved admin_plan as @admin_plan" do
        post :create, {:admin_plan => invalid_attributes}, valid_session
        expect(assigns(:admin_plan)).to be_a_new(Plan)
      end

      it "re-renders the 'new' template" do
        post :create, {:admin_plan => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  xdescribe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested admin_plan" do
        plan = Plan.create! valid_attributes
        put :update, {:id => plan.to_param, :admin_plan => new_attributes}, valid_session
        plan.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested admin_plan as @admin_plan" do
        plan = Plan.create! valid_attributes
        put :update, {:id => plan.to_param, :admin_plan => valid_attributes}, valid_session
        expect(assigns(:admin_plan)).to eq(plan)
      end

      it "redirects to the admin_plan" do
        plan = Plan.create! valid_attributes
        put :update, {:id => plan.to_param, :admin_plan => valid_attributes}, valid_session
        expect(response).to redirect_to(plan)
      end
    end

    describe "with invalid params" do
      it "assigns the admin_plan as @admin_plan" do
        plan = Plan.create! valid_attributes
        put :update, {:id => plan.to_param, :admin_plan => invalid_attributes}, valid_session
        expect(assigns(:admin_plan)).to eq(plan)
      end

      it "re-renders the 'edit' template" do
        plan = Plan.create! valid_attributes
        put :update, {:id => plan.to_param, :admin_plan => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  xdescribe "DELETE destroy" do
    it "destroys the requested admin_plan" do
      plan = Plan.create! valid_attributes
      expect {
        delete :destroy, {:id => plan.to_param}, valid_session
      }.to change(Plan, :count).by(-1)
    end

    it "redirects to the admin_plans list" do
      plan = Plan.create! valid_attributes
      delete :destroy, {:id => plan.to_param}, valid_session
      expect(response).to redirect_to(admin_plans_url)
    end
  end
end
