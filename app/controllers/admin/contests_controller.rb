class Admin::ContestsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @contests = Contest.all
  end

  # GET /admin/pages/1
  # GET /admin/pages/1.json
  def show

    if params[:keyword].present?
      @locations = Location.where('city LIKE ? OR state LIKE ?', "%#{params[:keyword]}%", "%#{params[:keyword]}%")
      render :json=>@locations.to_json
    elsif params[:contestid].present?
      @contest_id = params[:contestid]
      @contest = Contest.find(@contest_id)
      @contest.update_attributes(:status => "deleted")
      @result = "success"
      render :json => @result.to_json
    else
      @contest = Contest.find(params[:id])
      @users = @contest.contest_actions.map{|x| x.user_id}.uniq
      @summary = []
      @users.each do |u|
        @user = User.find(u)
        @photo_action = @contest.contest_actions.where("photo_url != '' and photo_url is not null and user_id=?", u).count
        @facebook_action = @contest.contest_actions.where(:facebook => true, :user_id=> u).count
        @twitter_action = @contest.contest_actions.where(:twitter => true, :user_id=> u).count
        @instagram_action = @contest.contest_actions.where(:instagram => true, :user_id=> u).count
        @grade_action = @contest.contest_actions.where("grade !='' and grade is not null and user_id=?", u).count
        @total_action = @photo_action + @facebook_action + @twitter_action + @instagram_action + @grade_action
        @summary.push({
          "contest_name"=> @contest.name,
          "user_name"=> @user.first_name + " " + @user.last_name,
          "photo_action"=> @photo_action,
          "facebook_action"=> @facebook_action,
          "twitter_action"=> @twitter_action,
          "instagram_action"=> @instagram_action,
          "grade_action"=> @grade_action,
          "total_action"=> @total_action
          })
      end
      @today = Date.today

      respond_to do |format|
        format.html
        format.csv { send_data export_csv1(@contest.contest_actions) }
      end
    end
  end

  def export_csv1(contest_actions)
    CSV.generate do |csv|
      csv << ["First Name","Last Name","Email","Restaurant","Menu Item","Action", "Data","Date Submitted","Status"]
      contest_actions.each do |c|
        csv << [c.user.first_name,c.user.last_name,c.user.email,c.location.name,c.item_name,"Photo", c.photo_url.tr(" ","+"), c.created_at.in_time_zone(c.location.timezone).strftime("%d/%m/%Y"), c.status]

        if c.facebook.present?
          csv << [c.user.first_name,c.user.last_name,c.user.email,c.location.name,c.item_name,"Facebook", c.facebook, c.created_at.in_time_zone(c.location.timezone).strftime("%d/%m/%Y"), c.status]
        end
        if c.twitter.present?
          csv << [c.user.first_name,c.user.last_name,c.user.email,c.location.name,c.item_name,"Twitter", c.twitter, c.created_at.in_time_zone(c.location.timezone).strftime("%d/%m/%Y"), c.status]
        end
        if c.instagram.present?
          csv << [c.user.first_name,c.user.last_name,c.user.email,c.location.name,c.item_name,"Instagram", c.instagram, c.created_at.in_time_zone(c.location.timezone).strftime("%d/%m/%Y"), c.status]
        end
        if c.grade.present?
          @temp = c.grade
          if c.comment.present?
            @temp += "-"+c.comment
          end
          csv << [c.user.first_name,c.user.last_name,c.user.email,c.location.name,c.item_name,"Grade", @temp, c.created_at.in_time_zone(c.location.timezone).strftime("%d/%m/%Y"), c.status]
        end
      end
    end
  end

  # GET /admin/pages/new
  # GET /admin/pages/new.json
  def new
    @contest= Contest.new
    @tags = ["Select Location Tag"]
    @tags = @tags.concat(Location.pluck('DISTINCT city')).concat(Location.pluck('DISTINCT state'))

  end

  # GET /admin/pages/1/edit
  def edit
    @contest_id = params[:id]
    @contest = Contest.find(@contest_id)
    @restaurants = Location.where(:id => @contest[:restaurants].split(",").map { |s| s.to_i })

    @tags = ["Select Location Tag"]
    @tags = @tags.concat(Location.pluck('DISTINCT city')).concat(Location.pluck('DISTINCT state'))
  end

  # POST /admin/pages
  # POST /admin/pages.json
  def create
    @contest = Contest.new(params[:contest])

    if params[:restaurant].present?
      @contest.restaurants = params[:restaurant].join(",");
    else
      @contest.restaurants = ""
    end
    @contest.status = "Pending";

    @tags = ["Select Location Tag"]
    @tags = @tags.concat(Location.pluck('DISTINCT city')).concat(Location.pluck('DISTINCT state'))
    respond_to do |format|
      if @contest.save
        format.html { redirect_to admin_contests_url, notice: 'Contest was successfully created.' }
        format.json { render json: @contest, status: :created, location: @contest }
      else
        format.html { render action: "new" }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/pages/1
  # PUT /admin/pages/1.json
  def update
    @contest = Contest.find(params[:id])

    if params[:restaurant].present?
      @contest.restaurants = params[:restaurant].join(",");
    else
      @contest.restaurants = ""
    end

    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        format.html { redirect_to admin_contests_url, notice: 'Contest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @contest.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_status
    @action_ids = params[:contest_action_ids]
    @status = params[:status]
    @action_ids.each do |a|
      @action = ContestAction.find(a)
      @action.update_attributes({status: @status})
      if @status=="Approved"

      end
    end

    render status: 200, json: { status: :success}
  end
  # DELETE /admin/pages/1
  # DELETE /admin/pages/1.json
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to admin_contests_url }
      format.json { head :no_content }
    end
  end
end
