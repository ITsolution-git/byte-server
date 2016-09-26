module MenusManagement
  class CopySharedController< ::ApplicationController
    respond_to :js

    def create
      menu = Menu.where(id: params[:menu_id]).first
      unless menu.try(:is_shared?)
        flash[:error] = 'Menu is not shared!'
        return render 'menus_management/copy_shared/create_error'
      end

      @restaurant = Location.where(id: params[:restaurant_id]).first
      
      if @restaurant.present?
        job_id = MenuCopier.create(location_id: @restaurant.id, menu_id: menu.id)
        @restaurant.copy_shared_menu_statuses.create!(job_id: job_id, menu_name: "Copy of #{menu.name}")
        flash[:success] = 'Menu copying was successfully scheduled'
      else
        flash[:error] = 'Menu copying failed'
      end
    end

    def status
      @restaurant = Location.where(id: params[:restaurant_id]).first
      @complete_menus = @restaurant.copy_shared_menu_statuses.select do |status|
        res = Resque::Plugins::Status::Hash.get(status.job_id) and res.completed? && !res.failed?
      end
      @restaurant.copy_shared_menu_statuses.where(id: @complete_menus.map(&:id)).destroy_all
    end
  end
end
