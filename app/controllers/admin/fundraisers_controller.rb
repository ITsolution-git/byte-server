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
    @type_array = Fundraiser.select(:division_type).uniq
    @type_array.uniq(true);
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
    # if params[:division_public_id].present?
    #   preloaded = Cloudinary::PreloadedFile.new(params[:division_public_id])         
    #   raise "Invalid upload signature" if !preloaded.valid?
    #   @fundraiser.division_image = preloaded.identifier
    # end
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
    # if @fundraiser.division_image != params[:division_public_id] and params[:division_public_id].present?
    #   preloaded = Cloudinary::PreloadedFile.new(params[:division_public_id])         
    #   raise "Invalid upload signature" if !preloaded.valid?
    #   @fundraiser.division_image = preloaded.identifier
    # end
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

  def getdivisionimage

    @fundraiser = Fundraiser.find(params[:id])
    # if @fundraiser.division_image != params[:division_public_id] and params[:division_public_id].present?
    #   preloaded = Cloudinary::PreloadedFile.new(params[:division_public_id])         
    #   raise "Invalid upload signature" if !preloaded.valid?
    #   @fundraiser.division_image = preloaded.identifier
    # end
    render :json => {:division_image => @fundraiser[:division_image], :success=>1}.to_json

  end
  def gettype

    @fundraiser = Fundraiser.find(params[:id])

    @type = FundraiserType.find(params[:type_id])
    render :json => {:data => @type}.to_json

  end
  def addtype

    @fundraiser = Fundraiser.find(params[:id])
    @type = FundraiserType.create(:name=>params[:name])
    if params[:image].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:image])         
      raise "Invalid upload signature" if !preloaded.valid?
      @type.image = preloaded.identifier
    else
      render :json => {:success=>1}.to_json
    end
    @fundraiser.fundraiser_types << @type
    render :json => {:obj => @type, :success=>1}.to_json

  end
end
