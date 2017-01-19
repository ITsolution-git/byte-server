# require 'rqrcode'

class RewardsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_reward, only: [:show, :edit, :update, :destroy, :print_qr_code]
  before_filter :set_restaurant, :set_rewards, :populate_array
  before_filter :adjust_timezone, only: [:create, :update]

  # GET /rewards
  # GET /rewards.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rewards }
    end
  end

  # GET /rewards/1
  # GET /rewards/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reward }
    end
  end

  # GET /rewards/new
  # GET /rewards/new.json
  def new
    @reward = @restaurant.rewards.build
    @reward.share_link = SecureRandom.hex(5)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reward }
    end
  end

  # GET /rewards/1/edit
  def edit
    @qr = RQRCode::QRCode.new(@reward.id.to_s, :size => 5, :level => :h )
    @reward.share_link = SecureRandom.hex(5) if @reward.share_link.blank?
  end

  # POST /rewards
  # POST /rewards.json
  def create
    @reward = @restaurant.rewards.build(params[:reward])

    if params[:logo_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:logo_public_id])
      raise "Invalid upload signature" if !preloaded.valid?
      @reward.photo = Cloudinary::Utils.cloudinary_url(preloaded.identifier)
    end

    respond_to do |format|
      if @reward.save
        format.html { redirect_to restaurant_rewards_path(@restaurant), notice: 'Reward was successfully created.' }
        format.json { render json: @reward, status: :created, location: @reward }
      else
        format.html { render action: "new" }
        format.json { render json: @reward.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rewards/1
  # PUT /rewards/1.json
  def update
    if params[:logo_public_id].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:logo_public_id])
      raise "Invalid upload signature" if !preloaded.valid?
      @reward.photo = Cloudinary::Utils.cloudinary_url(preloaded.identifier)
    end
    
    respond_to do |format|
      if @reward.update_attributes(params[:reward])
        format.html { redirect_to restaurant_rewards_path(@restaurant), notice: 'Reward was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reward.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rewards/1
  # DELETE /rewards/1.json
  def destroy
    @reward.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to restaurant_rewards_path(@restaurant) }
      format.json { head :no_content }
    end
  end

  # Set Restaurant Object
  def set_restaurant
    @restaurant = Location.find(params[:restaurant_id])
  end
  #prize_type 0:custom ,1:loyalty, 2:deals near me. refer to @prizeTypes in populate_array
  def set_rewards
    @rewards = Reward.where(location_id: @restaurant.id)
    @rewards_loyalty = Reward.where(location_id: @restaurant.id, prize_type: 1)
    @rewards_dealnearme = Reward.where(location_id: @restaurant.id, prize_type: 2)
    @rewards_custom = Reward.where(location_id: @restaurant.id, prize_type: 0)
  end

  def populate_array
    @timezones = [
      ["Default (UTC)", "UTC"],
      ["Pacific", "Pacific Time (US & Canada)"],
      ["Mountain", "Mountain Time (US & Canada)"],
      ["Central", "Central Time (US & Canada)"],
      ["Eastern", "Eastern Time (US & Canada)"]
    ]
    if params[:action] == "index" ||  params[:action] == "create"
      @prizeTypes = [
        ["Custom" ,0],
        ["Loyalty", 1],
        ["Deals Near Me", 2]
      ]
    elsif params[:action] == "new" 
      @prizeTypes = [
        ["Custom" ,0],
      ]
      if @rewards_loyalty.count == 0
        @prizeTypes << ["Loyalty", 1]
      end
      if @rewards_dealnearme.count == 0
        @prizeTypes << ["Deals Near Me", 2]
      end
    else
      @prizeTypes = [
        ["Custom" ,0],
      ]
      if @rewards_loyalty.count == 0 || @reward.prize_type == 1
        @prizeTypes << ["Loyalty", 1]
      end
      if @rewards_dealnearme.count == 0 || @reward.prize_type == 2
        @prizeTypes << ["Deals Near Me", 2]
      end
    end
  end

  def adjust_timezone
    # if params[:reward][:available_from].present? and params[:reward][:expired_until].present?
    #   available = params[:reward][:available_from] += " #{params[:reward][:timezone]}"
    #   expired = params[:reward][:expired_until] += " #{params[:reward][:timezone]}"
    #   params[:reward][:available_from] = available.to_datetime
    #   params[:reward][:expired_until] = expired.to_datetime
    # end
    if params[:reward][:share_link].present?
      params[:reward][:share_link] = params[:reward][:share_link].parameterize
    end
  end

  def fetch_reward
    @reward = Reward.find(params[:id])
  end

  def print_qr_code
    pdf_reward_name = @reward.name.downcase.gsub(/\W/, "")
    @qr = RQRCode::QRCode.new(@reward.id.to_s, :size => 5, :level => :h )
    pdf_render_hash = {}
    pdf_render_hash[:pdf] = "print_qr_code_#{pdf_reward_name}.pdf"
    pdf_render_hash[:page_size] = 'A4'
    pdf_render_hash[:margin] = { :top => 10, :left => 15, :bottom => 10, :right => 15 }
    pdf_render_hash[:orientation] = 'Portrait'

    respond_to do |format|
      format.pdf do
        render pdf_render_hash
      end
    end
  end
end
