class ServersController < ApplicationController
  load_and_authorize_resource
  def edit
    @server = Server.find(params[:id])
    @server_avatar = @server.avatar
    @server_avatar ||= @server.build_avatar
    @restaurant = Location.find(@server.location_id)
    @server_array = Server.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
    respond_to do |format|
      format.js
    end
  end
  def update
    @server = Server.find(params[:id])
    @server_old = @server.dup
    @server_old.server_avatar = @server.server_avatar
    @server_avatar = ServerAvatar.where('server_token = ?', @server.token).last
    @server.server_avatar = @server_avatar if not @server_avatar.nil?
    respond_to do |format|
      if @server.update_attributes(params[:server])
        ServerAvatar.destroy_all(['server_token = ? AND id != ?', @server.token, @server_avatar.id]) if not @server_avatar.nil?
        @restaurant = Location.find(@server.location_id)
        @server_array = Server.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
      end
      format.js
    end
  end
  def destroy
    @server = Server.find(params[:id])
    @restaurant = Location.find(@server.location_id)
    @menu = @restaurant.menus.new
    @menus_array = @restaurant.menus.order('name').all.sort_by!{ |m| m.name.downcase }
    begin
      @server.destroy
    rescue ActiveRecord::DeleteRestrictionError => ex
      puts "@@ ", ex.message
    end
    @server_array = Server.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }
  end

  def batch_delete
    params[:items_to_delete].each do |server_id|
      Server.find(server_id).destroy
    end
    render json: {}, status: :ok
  end
end
