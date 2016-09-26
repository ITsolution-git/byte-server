class Admin::AppServicesController < ApplicationController
  # GET /admin/app_services
  # GET /admin/app_services.json
  def index
    @app_services = AppService.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @app_services }
    end
  end

  # GET /admin/app_services/1
  # GET /admin/app_services/1.json
  def show
    @app_service = AppService.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_service }
    end
  end

  # GET /admin/app_services/new
  # GET /admin/app_services/new.json
  def new
    @app_service = AppService.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app_service }
    end
  end

  # GET /admin/app_services/1/edit
  def edit
    @app_service = AppService.find(params[:id])
  end

  # POST /admin/app_services
  # POST /admin/app_services.json
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

  # PUT /admin/app_services/1
  # PUT /admin/app_services/1.json
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

  # DELETE /admin/app_services/1
  # DELETE /admin/app_services/1.json
  def destroy
    @app_service = AppService.find(params[:id])
    @app_service.destroy

    respond_to do |format|
      format.html { redirect_to admin_app_services_url }
      format.json { head :no_content }
    end
  end
end
