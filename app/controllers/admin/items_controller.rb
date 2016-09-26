class Admin::ItemsController < ApplicationController
# GET /items
# GET /items.json
  def index
    @location = Location.find(params[:location_id])
    @items = @location.items

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @location= Location.find(params[:location_id])
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @location = Location.find(params[:location_id])
    @item = @location.items.new
    3.times do
      @item.item_images.build
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @location = Location.find(params[:location_id])
    @item = Item.find(params[:id])
    img_count = 3 - @item.item_images.count
    img_count.times {@item.item_images.build}
  end

  # POST /items
  # POST /items.json
  def create
    @location = Location.find(params[:location_id])
    @item = @location.items.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to [:admin,@location,@item], notice: 'Item was successfully created.' }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @location= Location.find(params[:location_id])
    @item = Item.find(params[:id])

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to [:admin,@location,@item], notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @location= Location.find(params[:location_id])
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to admin_location_items_path(@location) }
      format.json { head :no_content }
    end
  end
end
