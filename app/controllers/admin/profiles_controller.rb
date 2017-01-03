class Admin::ProfilesController < ApplicationController
  before_filter :authenticate_user!
  def index
    @profiles = UserProfile.where(:user_id => current_user.id)
  end

  # GET /admin/pages/1
  # GET /admin/pages/1.json
  def show
    if params[:profile_order].present?
        @order = params[:profile_order].map {|s| s.to_i}
        index = 1;
        @order.each do |o|
          @profile = UserProfile.find(o)
          @profile.update_attributes(:order_num => index)
          index +=1
        end
    elsif params[:status].present?
      @data = params[:status].split("_")
      @profile = UserProfile.find(@data[0])
      if @data[1].to_i == 1
        @profile.update_attributes(:publish_date => Time.now.strftime("%d.%m.%Y | %H:%M"))
      elsif @data[1].to_i == 0
        @profile.update_attributes(:unpublish_date => Time.now.strftime("%d.%m.%Y | %H:%M"))
      elsif @data[1].to_i ==2
        @profile.destroy
      end
    end
    render layout: false
  end

  # GET /admin/pages/new
  # GET /admin/pages/new.json
  def new
    @profile= UserProfile.new
    @tags = CuisineType.all
    @keys = ItemKey.where(:is_global => true)
    @contests = Contest.all
    @fundraisers = Fundraiser.all
  end

  # GET /admin/pages/1/edit
  def edit
    @profile_id = params[:id]
    @profile = UserProfile.find(params[:id])
    if @profile[:tags].present?
      @prev_tags = @profile[:tags].split(",").map { |s| s.to_i }.to_json
    else
      @prev_tags = [].to_json
    end
    @tags = CuisineType.all
    @keys = ItemKey.where(:is_global => true)
    @contests = Contest.all
    @fundraisers = Fundraiser.all
    @profiles = UserProfile.where(:user_id => current_user.id)
  end

  # POST /admin/pages
  # POST /admin/pages.json
  def create
    @profile = UserProfile.new(params[:user_profile])
    if params[:tags].present?
      @profile[:tags] = params[:tags].join(",")
    end

    respond_to do |format|
      if @profile.save
        format.html { redirect_to admin_profiles_url, notice: 'Profile was successfully created.' }
        format.json { render json: @profile, status: :created, location: @profile }
      else
        format.html { render action: "new" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/pages/1
  # PUT /admin/pages/1.json
  def update
    @profile = UserProfile.find(params[:id])
    if params[:tags].present?
      @profile[:tags] = params[:tags].join(",")
    end

    respond_to do |format|
      if @profile.update_attributes(params[:user_profile])
        format.html { redirect_to admin_profiles_url, notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/pages/1
  # DELETE /admin/pages/1.json
  def destroy
    @profile = UserProfile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to admin_profiles_url }
      format.json { head :no_content }
    end
  end
  def order
    @order = params[:profile_order]
    render json: @order
  end
end
