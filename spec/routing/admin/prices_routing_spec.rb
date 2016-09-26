require 'rails_helper'

RSpec.describe Admin::PricesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/admin/prices").to route_to("admin/prices#index")
    end

    it "routes to #new" do
      expect(:get => "/admin/prices/new").to route_to("admin/prices#new")
    end

    it "routes to #show" do
      expect(:get => "/admin/prices/1").to route_to("admin/prices#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/admin/prices/1/edit").to route_to("admin/prices#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/admin/prices").to route_to("admin/prices#create")
    end

    it "routes to #update" do
      expect(:put => "/admin/prices/1").to route_to("admin/prices#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/admin/prices/1").to route_to("admin/prices#destroy", :id => "1")
    end

  end
end
