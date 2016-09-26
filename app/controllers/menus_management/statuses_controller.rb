module MenusManagement
  class StatusesController < ::ApplicationController
    respond_to :js
    expose(:menu)

    def update
      if menu.update_attributes(params[:menu])
        flash.now[:success] = "Menu was #{menu.is_shared? ? 'shared' : 'unshared'}"
        render 'menus_management/status/update_success'
      else
        flash.now[:error] = menu.errors.full_messages.to_sentence
        render 'menus_management/status/update_error'
      end
    end
  end
end
