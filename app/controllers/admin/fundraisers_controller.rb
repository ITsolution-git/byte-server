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
    type_array = Fundraiser.select(:division_type).uniq
    type_array.uniq(true);
    @types = [];
    type_array.each do |type|
      @types<<type[:division_type]
    end 
    @fundraiser = Fundraiser.new
    @fundraiser.status = 2;
    @type_array = Fundraiser.select(:division_type).uniq
    @type_array.uniq(true);
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /fundraisers/1/edit
  def edit
    type_array = Fundraiser.select(:division_type).uniq
    type_array.uniq(true);
    @types = [];
    type_array.each do |type|
      @types<<type[:division_type]
    end
    @fundraiser = Fundraiser.find(params[:id])
  end

  # POST /fundraisers
  # POST /fundraisers.json
  def create
    type_array = Fundraiser.select(:division_type).uniq
    type_array.uniq(true);
    @types = [];
    type_array.each do |type|
      @types<<type[:division_type]
    end
    @fundraiser = Fundraiser.new(params[:fundraiser])
    if params[:logo_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:logo_public_id])         
      raise "Invalid upload signature" if !preloaded.valid?
      @fundraiser.logo = preloaded.identifier
    end
    if params[:division_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:division_public_id])         
      raise "Invalid upload signature" if !preloaded.valid?
      @fundraiser.division_image = preloaded.identifier
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
    if @fundraiser.logo != params[:logo_public_id] and params[:logo_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:logo_public_id])         
      raise "Invalid upload signature" if !preloaded.valid?
      @fundraiser.logo = preloaded.identifier

    end
    if @fundraiser.division_image != params[:division_public_id] and params[:division_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:division_public_id])         
      raise "Invalid upload signature" if !preloaded.valid?
      @fundraiser.division_image = preloaded.identifier
    end
    type_array = Fundraiser.select(:division_type).uniq
    type_array.uniq(true);
    @types = [];
    type_array.each do |type|
      @types<<type[:division_type]
    end
    puts params[:fundraiser]
    puts "$"*100
    puts @fundraiser.credit_card_type
    respond_to do |format|
      if @fundraiser.update_attributes(params[:fundraiser])
        format.html { redirect_to admin_fundraisers_url, notice: 'Fundraiser was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /fundraisers/1
  # DELETE /fundraisers/1.json
  def destroy
    @fundraiser = Fundraiser.find(params[:id])
    @fundraiser.destroy

    respond_to do |format|
      format.html { redirect_to admin_fundraisers_url }
    end
  end
end
