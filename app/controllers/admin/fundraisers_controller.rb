class Admin::FundraisersController < ApplicationController
  # GET /fundraisers
  # GET /fundraisers.json
  def index
    @fundraisers = Fundraiser.all
     respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fundraisers }
    end
  end

  # GET /fundraisers/1
  # GET /fundraisers/1.json
  def show
    @fundraiser = Fundraiser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fundraiser }
    end
  end

  # GET /fundraisers/new
  # GET /fundraisers/new.json
  def new
    @fundraiser = Fundraiser.new
    @fundraiser.status = 2;
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /fundraisers/1/edit
  def edit
    @fundraiser = Fundraiser.find(params[:id])
  end

  # POST /fundraisers
  # POST /fundraisers.json
  def create
    @fundraiser = Fundraiser.new(params[:fundraiser])
    if params[:logo_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:logo_public_id])         
      raise "Invalid upload signature" if !preloaded.valid?
      @fundraiser.logo = preloaded.identifier
    end
    respond_to do |format|
      if @fundraiser.save
        format.html { redirect_to admin_fundraisers_url, notice: 'Fundraiser was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /fundraisers/1
  # PUT /fundraisers/1.json
  def update
    @fundraiser = Fundraiser.find(params[:id])
    puts @fundraiser
    if @fundraiser.logo != params[:logo_public_id] and params[:logo_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:logo_public_id])         
      raise "Invalid upload signature" if !preloaded.valid?
      @fundraiser.logo = preloaded.identifier

    end
    respond_to do |format|
      if @fundraiser.update_attributes(params[:fundraiser])
        format.html { redirect_to admin_fundraisers_url, notice: 'Fundraiser was successfully updated.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # DELETE /fundraisers/1
  # DELETE /fundraisers/1.json
  def destroy
    @fundraiser = Fundraiser.find(params[:id])
    @fundraiser.destroy

    respond_to do |format|
      format.html { redirect_to fundraisers_url }
      format.json { head :no_content }
    end
  end
end
