class Admin::PackagesController < ApplicationController
  before_filter :authenticate_user!

  def index
    @packages = PackageFetcher.new.packages
    authorize! :manage, @packages
  end

  def status
    package = Admin::Package.find_or_create_by_package_id(params[:id])
    if package.update_attributes(enabled: params[:status].present?)
      flash.now[:success] = 'Status successfully toggled'
    else
      flash.now[:error] = package.errors.full_messages.to_sentence
    end
  end
end
