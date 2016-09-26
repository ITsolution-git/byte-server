class ItemOptionController < ApplicationController

	def edit
		@item_option = ItemOption.find(params[:id])
		@item_option_array = ItemOption.where("is_deleted = ? AND location_id = ?", 0, @item_option.location_id).sort_by!{ |m| m.name.downcase }

		@restaurant = Location.find(@item_option.location_id)
		# @cat_array = Category.where('location_id = ?',@restaurant.id).sort_by!{ |m| m.name.downcase }
		respond_to do |format|
			format.js
		end
	end

	def update
		opt = params[:item_option]
		@item_option = ItemOption.find(params[:id])
		@item_option_old = @item_option.dup

		test = ItemOption.new
		test.name = opt["name"]
		test.only_select_one = opt["select_one"].nil? ? 0 : 1

		opt['group'].each_with_index do |i, index|
			unless i['add_on'].nil? and i['price'].nil?
				temp = ItemOptionAddon.new
				temp.id = index
				temp.name = i['add_on']
				temp.price = i['price']
				temp.item_option_id = @item_option.id
				temp.is_selected = i['selected'] == 'on' ? 1 : 0

				test.item_option_addons.push(temp)
			end
		end

		@is_changed = true
		if (@item_option===test)
			@is_changed = false
		else
			@item_option.update_attributes(
				:name => opt["name"],
				:only_select_one => opt["select_one"].nil? ? 0 : 1
			)

			@item_option.item_option_addons.destroy_all
			opt['group'].each_with_index do |i, index|
				unless i['add_on'].nil? and i['price'].nil?
					ItemOptionAddon.create(
						:name => i['add_on'],
						:price => i['price'],
						:item_option_id => @item_option.id,
						:is_selected => i['selected'] == 'on' ? 1 : 0
					)
				end
			end
		end #end if (@item_option===test)
		@restaurant = Location.find(@item_option.location_id)
		@item_option_array = @restaurant.item_options.where("is_deleted = ?", 0).sort_by!{ |m| m.name.downcase }
		@item = Item.new
		@item_image = ItemImage.new
		@item_array = Item.where('location_id = ?', @restaurant.id).sort_by!{ |m| m.name.downcase }

		respond_to do |format|
			format.js
		end
	end

	def destroy
		@item_option = ItemOption.find(params[:id])
		@restaurant = Location.find(@item_option.location_id)
		@item_option.update_attributes(:is_deleted => 1)
		@item_option.item_option_addons.update_all("is_deleted = 1")

		@item_option_array = ItemOption.where("is_deleted = ? AND location_id = ?", 0, @item_option.location_id).sort_by!{ |m| m.name.downcase }
		@item = Item.new
		@item_image = ItemImage.new
		@item_array = Item.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id])
		@key_array = ItemKey.find(:all,:order=>'name ASC',:conditions=>['location_id=?',@restaurant.id]).sort_by!{ |m| m.name.downcase }

		respond_to do |format|
			format.js
		end
	end

  def batch_delete
    params[:items_to_delete].each do |item_option_id|
      ItemOption.find(item_option_id).destroy
    end
    render json: {}, status: :ok
  end
end
