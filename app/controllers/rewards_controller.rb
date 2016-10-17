class RewardsController < ApplicationController
  before_filter :authenticate_user!, :set_restaurant, :set_rewards, :populate_timezones
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
    @reward = Reward.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @reward }
    end
  end

  # GET /rewards/new
  # GET /rewards/new.json
  def new
    @reward = @restaurant.rewards.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reward }
    end
  end

  # GET /rewards/1/edit
  def edit
    @reward = Reward.find(params[:id])
  end

  # POST /rewards
  # POST /rewards.json
  def create
    @reward = @restaurant.rewards.build(params[:reward])

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
    @reward = Reward.find(params[:id])

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
    @reward = Reward.find(params[:id])
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

  def set_rewards
    @rewards = Reward.where(location_id: @restaurant.id)
  end

  def populate_timezones
    @timezones = [
      ["Default (UTC)", "UTC"],
      ["Pacific", "Pacific Time (US & Canada)"],
      ["Mountain", "Mountain Time (US & Canada)"],
      ["Central", "Central Time (US & Canada)"],
      ["Eastern", "Eastern Time (US & Canada)"]
    ]
  end

  def adjust_timezone
    if params[:reward][:available_from].present? and params[:reward][:expired_until].present?
      params[:reward][:available_from] += " #{params[:reward][:timezone]}"
      params[:reward][:expired_until] += " #{params[:reward][:timezone]}"
    end
  end
end
