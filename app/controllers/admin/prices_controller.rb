class Admin::PricesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /admin/prices
  # GET /admin/prices.json
  def index
    @prices = Price.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @prices }
    end
  end

  # GET /admin/prices/1
  # GET /admin/prices/1.json
  def show
    @price = Price.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @price }
    end
  end

  # GET /admin/prices/new
  # GET /admin/prices/new.json
  def new
    @price = Price.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @price }
    end
  end

  # GET /admin/prices/1/edit
  def edit
    @price = Price.find(params[:id])
  end

  # POST /admin/prices
  # POST /admin/prices.json
  def create
    @price = Price.new(params[:price])

    respond_to do |format|
      if @price.save
        format.html { redirect_to admin_price_path(@price), notice: 'Price was successfully created.' }
        format.json { render json: @price, status: :created, location: @price }
      else
        format.html { render action: "new" }
        format.json { render json: @price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/prices/1
  # PUT /admin/prices/1.json
  def update
    @price = Price.find(params[:id])

    respond_to do |format|
      if @price.update_attributes(params[:price])
        format.html { redirect_to admin_price_path(@price), notice: 'Price was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/prices/1
  # DELETE /admin/prices/1.json
  def destroy
    @price = Price.find(params[:id])
    @price.destroy

    respond_to do |format|
      format.html { redirect_to admin_prices_url }
      format.json { head :no_content }
    end
  end
  
  def user_assign_package
  end
  
  def assign_package
    if !params["package"].blank? && !params["package"]["user_id"].blank? && !params["package"]["price_id"].blank? 
      @user = User.find(params["package"]["user_id"])
      @user.update_attribute('price_id', params["package"]["price_id"])
      flash[:notice] = "Package was successfully assigned to #{@user.email}"
    else
      flash[:notice] = 'User and package should not be blank.'  
    end 
    redirect_to user_assign_package_admin_prices_path 
  end
end
