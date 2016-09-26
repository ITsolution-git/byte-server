class Admin::AccountsController < ApplicationController
  # GET /admin/accounts
  # GET /admin/accounts.json
  def index
    @restaurants = Location.all
    @user = current_user
    respond_to do |format|
      format.html
    end
  end

  # GET /admin/accounts/1
  # GET /admin/accounts/1.json
  def show
    @app_service = AppService.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_service }
    end
  end

  # GET /admin/accounts/new
  # GET /admin/accounts/new.json
  def new
    @app_service = AppService.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app_service }
    end
  end

  # GET /admin/accounts/1/edit
  def edit
    @app_service = AppService.find(params[:id])
  end

  # POST /admin/accounts
  # POST /admin/accounts.json
  def create
    @app_service = AppService.new(params[:app_service])

    respond_to do |format|
      if @app_service.save
        format.html { redirect_to admin_app_service_path(@app_service), notice: 'App service was successfully created.' }
        format.json { render json: @app_service, status: :created, location: @app_service }
      else
        format.html { render action: "new" }
        format.json { render json: @app_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/accounts/1
  # PUT /admin/accounts/1.json
  def update
    @app_service = AppService.find(params[:id])

    respond_to do |format|
      if @app_service.update_attributes(params[:app_service])
        format.html { redirect_to admin_app_service_path(@app_service), notice: 'App service was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/accounts/1
  # DELETE /admin/accounts/1.json
  def destroy
    @app_service = AppService.find(params[:id])
    @app_service.destroy

    respond_to do |format|
      format.html { redirect_to admin_accounts_url }
      format.json { head :no_content }
    end
  end
end
