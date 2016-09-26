class ComboItemsController < ApplicationController
  def edit
    @combo_item = ComboItem.find(params[:id])
    @restaurant = @combo_item.menu.location
    @main_items = @combo_item.menu.get_main_dish_except_combo_item(@combo_item.item_id)
    @categories = @combo_item.menu.get_categories_built
    @categories = @categories.sort_by!{ |m| m.name.downcase }
    @items = @combo_item.menu.get_items_built
    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
      AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)
      .sort_by!{ |m| m.name.downcase }
    respond_to do |f|
      f.js
    end
  end
  def update
    @restaurant = Location.find(params[:combo_item][:location_id])
    authorize! :read, @restaurant
    @combo_item = ComboItem.find(params[:id])
    @combo_item_old = @combo_item.dup
    @combo_item_old.combo_item_categories = @combo_item.combo_item_categories
    @combo_item_old.combo_item_items = @combo_item.combo_item_items
    @combo_item.name = params[:combo_item][:name]
    @combo_item.menu_id = params[:combo_item][:menu_id]
    @combo_item.item_id = params[:combo_item][:item_id]


    if params[:items] && params[:categories] && (!params[:qty].nil? && params[:qty].uniq != [""])\
     && (!params[:sequence].nil? && params[:sequence].uniq != [""])


      #if (params[:qty].uniq != [""]) && (params[:sequence].uniq != [""])
        if params[:combo_item][:check_combo_type] == 'pmi'
          @combo_item.combo_type = PMI_GMI
        elsif params[:combo_item][:check_combo_type] == 'gmi'
          @combo_item.combo_type = GMI_PMI
        end

         #ComboItemCategory.destroy_all(combo_item_id: @combo_item.id) if @combo_item.gmi?\
          # || @combo_item.cmi? && @combo_item.combo_type == 'PMI,GMI'
        #ComboItemItem.destroy_all(combo_item_id: @combo_item.id) if @combo_item.pmi?\
         #  || @combo_item.cmi? && @combo_item.combo_type == 'GMI,PMI'
        # Update PMI
        if params[:items]
          #ComboItemItem.destroy_all(combo_item_id: @combo_item.id)
          # If this combo is GMI, remove it
          ComboItemCategory.destroy_all(combo_item_id: @combo_item.id) if @combo_item.gmi?\
           || @combo_item.cmi?

          #@combo_item.combo_type = PMI
          old_ids = @combo_item.combo_item_items.map(&:item_id)
          items_removed = old_ids - params[:items].map {|x| x.to_i}
          items_added = params[:items].map {|x| x.to_i} - old_ids

          ComboItemItem.destroy_all(['combo_item_id = ? AND item_id IN (?)', @combo_item.id,
            items_removed])

          items_added.each do |item_id|
            # Need ensure build_menu created
            @combo_item.combo_item_items.build(item_id: item_id)
          end

          if @combo_item.save
            @combo_item = ComboItem.find(params[:id])
          end
        end

        # Update GMI
        if params[:categories] && (params[:qty].uniq != [""]) && (params[:sequence].uniq != [""])
          # If this combo is PMI, remove it
          #ComboItemItem.destroy_all(combo_item_id: @combo_item.id) if @combo_item.pmi?\
           #|| @combo_item.cmi?

          #@combo_item.combo_type = GMI
          params[:categories].each_with_index do |id, index|
            combo_item_category = ComboItemCategory \
              .find_by_combo_item_id_and_category_id(@combo_item.id, id)

            if combo_item_category.nil?
              combo_item_category = ComboItemCategory.new(
                combo_item_id: @combo_item.id,
                category_id: id
              )
            end
            qty = params[:qty][index].to_i
            sequence = params[:sequence][index].to_i
            if qty > 0
              combo_item_category.quantity = qty
              combo_item_category.sequence = sequence
              combo_item_category.save
            else
              # Remove GMI if category has no quantity
              combo_item_category.destroy
            end
          end

          # Update combo's info
          if @combo_item.save
            @combo_item = ComboItem.find(@combo_item.id)
          end
        end


    else
      # Update PMI
      if params[:items]
        # If this combo is GMI, remove it
        ComboItemCategory.destroy_all(combo_item_id: @combo_item.id) if @combo_item.gmi? \
        || @combo_item.cmi? && @combo_item.combo_type == PMI_GMI

        @combo_item.combo_type = PMI
        old_ids = @combo_item.combo_item_items.map(&:item_id)
        items_removed = old_ids - params[:items].map {|x| x.to_i}
        items_added = params[:items].map {|x| x.to_i} - old_ids

        ComboItemItem.destroy_all(['combo_item_id = ? AND item_id IN (?)', @combo_item.id,
          items_removed])

        items_added.each do |item_id|
          # Need ensure build_menu created
          @combo_item.combo_item_items.build(item_id: item_id)
        end

        if @combo_item.save
          @combo_item = ComboItem.find(params[:id])
        end
      end

      # Update GMI
      if params[:categories] && (params[:qty].uniq != [""]) && (params[:sequence].uniq != [""])

        # If this combo is PMI, remove it
        ComboItemItem.destroy_all(combo_item_id: @combo_item.id) if @combo_item.pmi?\
        || @combo_item.cmi? && @combo_item.combo_type == GMI_PMI

        @combo_item.combo_type = GMI
        params[:categories].each_with_index do |id, index|
          combo_item_category = ComboItemCategory \
            .find_by_combo_item_id_and_category_id(@combo_item.id, id)

          if combo_item_category.nil?
            combo_item_category = ComboItemCategory.new(
              combo_item_id: @combo_item.id,
              category_id: id
            )
          end
          qty = params[:qty][index].to_i
          sequence = params[:sequence][index].to_i
          if qty > 0
            combo_item_category.quantity = qty
            combo_item_category.sequence = sequence
            combo_item_category.save
          else
            # Remove GMI if category has no quantity
            combo_item_category.destroy
          end
        end

        # Update combo's info
        if @combo_item.save
          @combo_item = ComboItem.find(@combo_item.id)
        end
      end
    end



    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
        AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)
        .sort_by!{ |m| m.name.downcase }
    respond_to do |f|
      f.js
    end
  end

  def destroy
    @combo_item = ComboItem.find(params[:id])
    @restaurant = Location.find(@combo_item.menu.location_id)

    begin
      @combo_item.destroy
    rescue ActiveRecord::DeleteRestrictionError => e

    end

    @combo_item_array = ComboItem.joins(:menu).where('menus.location_id = ?
      AND menus.publish_status != ?', @restaurant.id, PUBLISH_STATUS)
      .sort_by!{ |m| m.name.downcase }
  end
end
