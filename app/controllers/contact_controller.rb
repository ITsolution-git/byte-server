class ContactController < ApplicationController
	before_filter :authenticate_user!
	before_filter :check_suspended, only: [:search]

	def search

		# This method needs to be refactored badly!

		@check = false
		@search_params = params[:search]

		# This varable is just used in search.html.erb 
		# Can't refactor this method now... there should just be one instance variable for location in the future
		@current_location = Location.find(params[:restaurant_id])

		#my contacts
		location_id = params[:restaurant_id]

		#check have restaurant in database
		unless location_id.nil?
			location = Location.find(location_id)
			unless location.nil?
				owner_id = location.owner_id
				if current_user.id.to_i == owner_id.to_i && current_user.owner?
					@check = true
				end
			end
		end

		location_arr = []
		@group_id = params[:group_id]
		@mycontact = nil
		if location_id.nil?
			@mycontact = 1
			if current_user.owner?
				location_arr = Location.where("owner_id=?", current_user.id)
			elsif current_user.admin?
				location_arr = Location.all
			end
			@restaurant_id = nil
		else
			@mycontact = 0
			location_arr = Location.where("slug=? || id =?", location_id, location_id)
			unless location_arr.empty?
				@restaurant = location_arr.first
				unless @restaurant.nil?
					@restaurant_id = @restaurant.id
				end
			end
		end
		@group = Group.where("location_id=?",@restaurant_id)
		location_id_arr = []

		location_arr.each do |loca|
			location_id_arr << loca.id
		end

		location_id_arr = location_id_arr.join(",")
		@customer = GroupUser.get_all_list_customers(location_id_arr, current_user.id)
		@customer_all = GroupUser.get_all_list_customers(location_id_arr, current_user.id)
		@checkins = Checkin.where(location_id: @current_location.id)
		@item_id = params[:item_id]
		@item_name = nil
		if !@item_id.nil?
			item = Item.find_by_id(@item_id)
			unless item.nil?
				@item_name = item.name
			end
			customer_favorite = GroupUser.get_user_favorite_items(@item_id)
			unless customer_favorite.empty?
				@customer = customer_favorite
			end
		end

		if !@group_id.nil?
			customer_arr_id = []
			user_arr_id = []
			unless @customer.empty?
				@customer.each do |cus|
					customer_arr_id << cus.id
				end
			end
			user_group = GroupUser.where("group_id=?", @group_id)
			unless user_group.empty?
				user_group.each do |user|
					user_arr_id << user.user_id
				end
			end
			user_group_arr = []
			unless user_arr_id.empty?
				user_arr_id.each do |id|
					if customer_arr_id.include?(id)
						user_group_arr << id
					end
				end
			end
			@customer = User.where("id IN (?) and is_register = ?",user_group_arr, 0)
		end

		if !@search_params.nil?
			customer_search_arr = User.search_customer_contact(@search_params)
			arr_customer = []
			@customer.each do |cu|
				arr_customer << cu.id
			end

			# This following serves no point in this controller (possible delete)
			user_prize_arr = []
			arr_customer.each do |user_id|
        last_user_prize = UserPrize.where(user_id: user_id).last
				unless last_user_prize.blank? || last_user_prize.status_prize.blank?
          user_prize_arr << user_id
				end
			end
			# end of possible delete

			user_common = []
			user_common = customer_search_arr
			user_common = user_common.uniq
			customer_search = []
			user_common.each do |id|
				if arr_customer.include?(id)
					customer_search << id
				end
			end
			@customer = User.where("id IN (?) and is_register = ?", customer_search, 0)
		end

		customer_contact = []
		@customer.each do |cus|
			unless location_id.nil?
				location = Location.find(location_id)
				customer_location = CustomersLocations.find_by_user_id_and_location_id(cus.id, location.id)
				if !customer_location.nil?
					customer_contact << cus if customer_location.is_deleted == 2
				end
			else
				customer_location = CustomersLocations.where("is_deleted = 2 AND user_id = ?", cus.id).first
				unless customer_location.nil?
					customer_contact << cus
				end
			end
		end
		@customer = @customer - customer_contact
		@customer =@customer.sort { |x,y| y.created_at <=> x.created_at}
		@customer = Kaminari.paginate_array(@customer).page(params[:page]).per(25)

		if @mycontact  == 0
			@items = Item.get_items_publish(@restaurant_id)
		end

		if @check == false && !current_user.admin? && @mycontact != 1
			respond_to do |format|
				format.html { render :file => "#{Rails.root}/public/restaurant", :layout => false }
			end
		end

		# Variable useed in CSV export.
		@item_comments = []
		@current_location.items.each do |item|
			item.item_comments.each do |item_comment|
				@item_comments << item_comment
			end
		end

		respond_to do |format|
			format.html
			format.csv do
				headers['Content-Disposition'] = "attachment; filename=\"restaurant-users.csv\""
				headers['Content-Type'] ||= 'text/csv'
			end
		end
	end

	def add_customer
	  @restaurant = params[:restaurant_id]
	  @customer_id = params[:customer_id]
	  @restaurant_id = nil
	  if @restaurant.nil?
	  	@mycontact = 1
	  else
	  	@mycontact = 0
	  	location = Location.where("slug=? || id =?", @restaurant, @restaurant)
	  	unless location.empty?
	  	  @restaurant_id = location.first.id
	  	end
	  end
	  @group = Group.where("location_id=?",@restaurant_id)
	  unless @group.empty?
	  	@group = @group.sort_by!{ |m| m.name.downcase }
	  end
	  @customer_id_lst = params[:customer_id]
	  respond_to do |format|
	  	format.js
	  end
	end

	def create_group
		group = params[:group]
		@group_name = params[:group][:name]
		@restaurant = params[:restaurant_id]
		restaurant_id = nil
		unless @restaurant.nil?
			location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		end
		unless location.empty?
			restaurant_id = location.first.id
		end
		@check = false
		unless @group_name.nil?
			group_check = Group.find_by_name_and_location_id(@group_name,restaurant_id)
			if !group_check.nil?
				@check = true
			end
		end
		if @check == false
			@customer_arr = params[:group][:customer_arr]
			unless @customer_arr.nil? || @customer_arr == ""
				@customer_arr =@customer_arr.split(',')
			end
			location_id = nil
			unless @restaurant.nil?
				location = Location.where("slug=? || id =?", @restaurant, @restaurant)
			end
			unless location.empty?
				location_id = location.first.id
			end
			@mycontact =nil
			if @restaurant.nil?
				@mycontact = 1
			else
				@mycontact= 0
			end
			unless group.nil?
			  unless @group_name.nil?
			  	new_group = Group.create({
	              :name => @group_name,
	              :location_id => location_id
	            })
	            unless new_group.nil?
	              unless @customer_arr.empty?
	            	@customer_arr.each do |cus|
			  			GroupUser.create({
			              :group_id => new_group.id.to_i,
			              :user_id => cus.to_i
			            })
			  		end
	              end
	            end
		    end
		  end
		  respond_to do |format|
            format.js #{ redirect_to search_restaurant_contact_index_path(restaurant), notice: 'Group added successfully' }
          end
		end
	end

	def add_group_user
	  customer_id = params[:customer_id].split(',')
	  @count = customer_id.count
	  group_id = params[:group_id]
	  group = Group.find_by_id(group_id)
	  @group_name = nil
	  unless group.nil?
	  	@group_name = group.name
	  end
	  @restaurant = params[:restaurant_id]

	  user_group = GroupUser.where("group_id=?", group_id)
	  user_arr = []
	  unless user_group.empty?
	  	user_group.each do |ug|
	  		user_arr << ug.user_id
	  	end
	  end

	  customer_update_arr = []
	  @customer_name_exist_arr = []

	  unless customer_id.empty? && user_arr.empty?
	  	customer_id.each do |u|
	  		if !user_arr.include?(u.to_i)
	  			customer_update_arr << u.to_i
	  		else
	  		  @customer_name_exist_arr << u.to_i
	  		end
	  	end
	  end




	  unless group_id.nil?
	  	@name_exist = []
	    unless @customer_name_exist_arr.empty?
	    	# @count = @count - @customer_name_exist_arr.count
		  	@customer_name_exist_arr.each do |id|
		  		group_user = GroupUser.find_by_user_id(id, group_id)
		  		unless group_user.nil?
		  			user_name = User.find_by_id(group_user.user_id)
		  			unless user_name.nil?
		  				@name_exist << user_name.name
		  			end
		  		end
		  	end
	    end
	  	unless customer_update_arr.empty?
	  		customer_update_arr.each do |cus|
	  			GroupUser.create({
	              :group_id => group_id.to_i,
	              :user_id => cus.to_i
	            })
	  		end
	  	end
	  end
	  respond_to do |format|
	  	format.js
	  end
	end

	def delete_group
		group_id = params[:group_id]
		@restaurant = params[:restaurant_id]
		location_id = nil
		unless @restaurant.nil?
			location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		end
		unless location.empty?
			location_id = location.first.id
		end
		unless group_id.nil? && location_id.nil?
			group = Group.where("location_id=? AND id=?", location_id, group_id)
			if !group.empty?
			  group.first.destroy
			end
		end
		respond_to do |format|
		  format.js
		end
	end

	def favourite_items
		@item_id = params[:item_id]
		@restaurant = params[:restaurant_id]
		@group_id = params[:group_id]

		location_id = nil
		unless @restaurant.nil?
			location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		end
		unless location.empty?
			location_id = location.first.id
		end
		unless location_id.nil?
		  @customer = GroupUser.get_user_favorite_items(location_id)
		end
		@customer_arr_id = []
		unless @customer.empty?
			@customer.each do |cu|
				@customer_arr_id << cu.id
			end
		end
		respond_to do |format|
			format.js
		end
	end

	def suspend_customer
		@customer_id = params[:customer_id]
		@restaurant = params[:restaurant_id]
		@group_id = params[:group_id]
		#location_id = nil
		#location = []
		#unless @restaurant.nil?
		 # location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		#end
		#unless location.empty?
		 # location_id = location.first.id
		#end
		#unless location_id.nil? && @customer_id.nil?
		#	location_user = CustomersLocations.find_by_location_id_and_user_id(location_id, @customer_id)
		#	if location_user.nil?
		#	  CustomersLocations.create({
	    #         :location_id => location_id.to_i,
	    #        :user_id => @customer_id.to_i,
	    #         :status => 1
	    #        })
		#	else
		#	  location_user.update_attribute(:status, 1)
		#	end
		#end
		respond_to do |format|
		  format.js
		end
	end

	def action_suspend_customer
		@customer_id = params[:customer_id]
		@restaurant = params[:restaurant_id]
		@group_id = params[:group_id]
		location_id = nil
		location = []
		@check_update = true
		unless @restaurant.nil?
		  location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		end
		unless location.empty?
		  location_id = location.first.id
		end
		unless location_id.nil? && @customer_id.nil?
			location_user = CustomersLocations.find_by_location_id_and_user_id(location_id, @customer_id)
			if location_user.nil?
			  CustomersLocations.create({
	              :location_id => location_id.to_i,
	              :user_id => @customer_id.to_i,
	              :is_deleted => 1
	            })
			else
			  location_user.update_attribute(:is_deleted, 1)
			end
		else
			@check_update = false
		end
		respond_to do |format|
		  format.js
		end
	end

	def un_suspend_customer
		@customer_id = params[:customer_id]
		@restaurant = params[:restaurant_id]
		@group_id = params[:group_id]
		#location_id = nil
		#location = []
		#unless @restaurant.nil?
		 # location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		#end
		#unless location.empty?
		 # location_id = location.first.id
		#end
		#unless location_id.nil? && @customer_id.nil?
		#	location_user = CustomersLocations.find_by_location_id_and_user_id(location_id, @customer_id)
		#	unless location_user.nil?
		#	  location_user.update_attribute(:status, 0)
		#	end
		#end
		respond_to do |format|
		  format.js
		end
	end

	def action_un_suspend_customer
		@customer_id = params[:customer_id]
		@restaurant = params[:restaurant_id]
		@group_id = params[:group_id]
		@check_update = true
		location_id = nil
		location = []
		unless @restaurant.nil?
		  location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		end
		unless location.empty?
		  location_id = location.first.id
		end
		unless location_id.nil? && @customer_id.nil?
			location_user = CustomersLocations.find_by_location_id_and_user_id(location_id, @customer_id)
			unless location_user.nil?
			  location_user.update_attribute(:is_deleted, 0)
			end
		else
			@check_update = false
		end
		respond_to do |format|
		  format.js
		end
	end

	def delete_customer
		@user_contact_delete = []
		@restaurant = params[:restaurant_id]
		location_id = []
		location = []
		restaurant_id = nil
		unless @restaurant.nil?
		  location = Location.where("slug=? || id =?", @restaurant, @restaurant)
		end
		unless location.empty?
		  location_id << location.first.id
		  restaurant_id = location.first.id
		end
		location_id =location_id.join(",")
		@user_contact_delete = params[:user_contact]
		unless @user_contact_delete.nil? || @user_contact_delete == ""
			@user_contact_delete = @user_contact_delete.split(',')
		end
		if !@user_contact_delete.nil?
			@group_id = params[:group_id]
			if @group_id.nil? || @group_id == ""
			  unless @user_contact_delete.empty?
			  	@user_contact_delete.each do |user|
			  		user_delete = CustomersLocations.find_by_user_id_and_location_id(user,restaurant_id)
			  		if user_delete.nil?
			  			CustomersLocations.create({
			              :location_id => restaurant_id,
			              :user_id => user,
			              :is_deleted => 2
			            })
			  		else
			  			user_delete.update_attribute(:is_deleted, 2)
			  		end
			  	 	order = Order.find_by_user_id_and_location_id(user,restaurant_id)
			  	 	unless order.nil?
			  	 		order.destroy
			  	 	end

			  	 	share_social = SocialShare.find_by_user_id_and_location_id(user,restaurant_id)
			  	 	unless share_social.nil?
			  	 		share_social.destroy
			  	 	end

			  	 	location_favorite = LocationFavourite.find_by_user_id_and_location_id(user,restaurant_id)
			  	 	unless location_favorite.nil?
			  	 		location_favorite.destroy
			  	 	end

			  	 	user_prize = GroupUser.get_delete_share_prize(location_id)
			  	 	unless user_prize.empty?
			  	 		user_prize.each do |user|
			  	 			if user.id == user
			  	 			  prize_share = SharePrize.find_by_from_user(user)
						  	   unless prize_share.nil?
						  	 	  prize_share.destroy
						  	   end
			  	 			end
			  	 		end
			  	 	end

			  	 	user_receive_prize = GroupUser.get_delete_receive_prize(location_id)
			  	 	unless user_receive_prize.empty?
			  	 		user_receive_prize.each do |user|
			  	 			if user.id == user
			  	 			  prize_receive = SharePrize.find_by_to_user_and_status(user, 1)
						  	   unless prize_shareprize_receive.nil?
						  	 	  prize_receive.destroy
						  	   end
			  	 			end
			  	 		end
			  	 	end

			  	 	user_favorite = GroupUser.get_delete_item_favorite(location_id)
			  	 	unless user_favorite.empty?
			  	 		user_favorite.each do |user|
			  	 			if user.id == user
			  	 			  item_fav = ItemFavourite.find_by_from_user(user)
						  	   unless item_fav.nil?
						  	 	  item_fav.destroy
						  	   end
			  	 			end
			  	 		end
			  	 	end

			  	 	user_notification = GroupUser.get_delete_notification(location_id)
			  	 	unless user_notification.empty?
			  	 		user_notification.each do |user|
			  	 			user_delete = User.find_by_id(user)
			  	 			email = nil
			  	 			unless user_delete.nil?
			  	 				email = user_delete.email
			  	 			end
			  	 			if user.email == email
			  	 			  notification = Notifications.find_by_to_user(email)
						  	   unless notification.nil?
						  	 	  notification.destroy
						  	   end
			  	 			end
			  	 		end
			  	 	end

			  	 end
			  end
			else
				unless @user_contact_delete.empty?
					@user_contact_delete.each do |id|
			  	 	  user_group = GroupUser.find_by_user_id_and_group_id(id.to_i, @group_id.to_i)
			  	 	  unless user_group.nil?
			  	 	  	user_group.destroy
			  	 	  end
			  	    end
				end
			end
		end
		respond_to do |format|
			format.js
		end
	end

	def delete_my_contact
		# location_my_contact = Location.where("owner_id=?", current_user.id)
		location_my_contact = Location.all

		location_id =[]
		unless location_my_contact.empty?
			location_my_contact.each do |loca|
				location_id << loca.id
			end
		end
		location_id =location_id.join(",")

		@user_id = params[:user_id]
		user_delete = User.find_by_id(@user_id)
	    unless user_delete.nil?
	    	unless location_my_contact.empty?
	    		location_my_contact.each do |l|
	    			unless l.id.nil?
	    			    user_delete = CustomersLocations.find_by_user_id_and_location_id(@user_id,l.id)
				  		if user_delete.nil?
				  			CustomersLocations.create({
				              :location_id => l.id,
				              :user_id => @user_id,
				              :is_deleted => 2
				            })
				  		else
				  			user_delete.update_attribute(:is_deleted, 2)
				  		end
	    			end
			  	end
	    	end

		  	order = Order.find_by_user_id(user_delete)
		  	unless order.nil?
		  	  order.destroy
		  	end

		  	share_social = SocialShare.find_by_user_id(user_delete)
		  	unless share_social.nil?
		  	  share_social.destroy
		  	end

		  	location_favorite = LocationFavourite.find_by_user_id(user_delete)
		  	unless location_favorite.nil?
		  	  location_favorite.destroy
		  	end

		  	user_prize = GroupUser.get_delete_share_prize(location_id)
		  	unless user_prize.empty?
		  	 	user_prize.each do |user|
		  	 		if user.id == user_delete
		  	 			prize_share = SharePrize.find_by_from_user(user_delete)
					  	unless prize_share.nil?
					  	 	prize_share.destroy
					  	end
		  	 		end
		  	 	end
		  	end

		  	user_receive_prize = GroupUser.get_delete_receive_prize(location_id)
		  	unless user_receive_prize.empty?
		  	 	user_receive_prize.each do |user|
		  	 		if user.id == user_delete
		  	 			prize_receive = SharePrize.find_by_to_user_and_status(user_delete, 1)
					  	unless prize_shareprize_receive.nil?
					  	 	prize_receive.destroy
					  	end
		  	 		end
		  	 	end
		  	 end

	  	 	user_favorite = GroupUser.get_delete_item_favorite(location_id)
	  	 	unless user_favorite.empty?
	  	 		user_favorite.each do |user|
	  	 			if user.id == user_delete
	  	 			  item_fav = ItemFavourite.find_by_from_user(user_delete)
				  	   unless item_fav.nil?
				  	 	  item_fav.destroy
				  	   end
	  	 			end
	  	 		end
	  	 	end

	  	 	user_notification = GroupUser.get_delete_notification(location_id)
	  	 	unless user_notification.empty?
	  	 		user_notification.each do |user|
	  	 			user_delete = User.find_by_id(user)
	  	 			email = nil
	  	 			unless user_delete.nil?
	  	 				email = user_delete.email
	  	 			end
	  	 			if user.email == email
	  	 			  notification = Notifications.find_by_to_user(email)
				  	   unless notification.nil?
				  	 	  notification.destroy
				  	   end
	  	 			end
	  	 		end
	  	 	end


		end
		respond_to do |format|
			format.html { redirect_to search_contact_index_path, notice: 'Contacts deleted.' }
		end
	end
end
