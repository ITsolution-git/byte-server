class DinnersController < ApplicationController
  def index
    @dinner = DinnerType.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @dinner = DinnerType.new
  end

  def create
    @dinner = DinnerType.new(params[:dinner_type])
    if @dinner.save
      redirect_to dinners_path, notice: "Successfully created dinner type."
    else
      render :new
    end
  end
  def show

  end
end
