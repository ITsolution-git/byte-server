module Api
  module V2
    class LocationsController < Api::BaseController
      respond_to :json

      def notifications
        @location = Location.find(params[:location_id])
        @location.contests=[]
        @messages = Location.get_global_message(current_user.email, @location.id).first
        # @points = @location.points_awarded_for_checkin + current_user.points
        # @prizes = Prize.get_unlocked_prizes_by_location(@location.id, @points, current_user.id)

        @unread_messages = @messages.present? ? @messages.unread : 0

        count = 0
        current_prizes = Prize.get_unlocked_prizes_by_location(@location.id, @location.id.total, current_user.id)
        prizes = current_prizes.concat(Prize.get_received_prizes(@location.id, current_user.id))
        prizes = Prize.reject_prizes_in_order(current_prizes, @location.id, current_user.id)
        prizes = Prize.hide_redeemed_prizes_after_three_hours(prizes)
        unless prizes.empty?
          prizes.each do |prize|
            if prize.date_time_redeem.nil?
              count = count + 1
            end
          end
        end

        # @unlocked_prizes = @prizes.count

        render :json => { :unread_messages => @unread_messages, :unlocked_prizes => count }
      end
      def create
        @res_locations = nearby_locations
        #@bt_subscriptions = Location.braintree_subscriptions(@locations)
        @locations=[]
        contests = Contest.all
        @res_locations.each do |l|
          l.contests=[]
          # l.messages=Location.get_global_message(current_user.email, l.id).first
          # @points = l.points_awarded_for_checkin + current_user.points
          # l.prizes = Prize.get_unlocked_prizes_by_location(l.id, @points, current_user.id)
          contests.each do |c|
            if Time.parse(c.start_date) < Time.now && Time.parse(c.end_date) > Time.now
              restaurants = c.restaurants.split(",").map { |s| s.to_i }
              if restaurants.include?(l.id)
                l.contests.push(c)
              end
            end
          end
          @locations.push(l)
        end

        # render :json => @locations
        return unless params[:tags].present?

        if params[:tags].select{|e| e[:type] == 'location'}.present?
          @locations = location(params[:tags].select{|e| e[:type] == 'location'}.map{|e| e[:name].upcase})
        end
        if params[:tags].select{|e| e[:type] == 'search'}.present?
          tag = params[:tags].select{|e| e[:type] == 'search'}.first
          @locations = Location.includes(:menus).where('(locations.name like ? OR locations.city like ?) AND menus.publish_status = 2', '%'+tag[:name]+'%', '%'+tag[:name]+'%')
        end
        if params[:tags].select{|e| e[:type] == 'cuisine'}.present?
          @locations = cuisine(@locations, params[:tags].select{|e| e[:type] == 'cuisine'}.map{|e| e[:name].upcase})
        end
        if params[:tags].select{|e| e[:type] == 'contest'}.present?
          @contest = Contest.find(params[:tags].select{|e| e[:type] == 'contest'}.map{|e| e[:name].to_i}[0])
          @locations = contest(@locations, @contest[:restaurants].split(",").map { |s| s.to_i })
        end
        if params[:tags].select{|e| e[:type] == 'menu_item'}.present?
          @locations = menu_item(@locations, params[:tags].select{|e| e[:type] == 'menu_item'}.map{|e| e[:name].upcase})
        end
        if params[:tags].select{|e| e[:type] == 'menu_item_key'}.present?
          @locations = menu_item_key(@locations, params[:tags].select{|e| e[:type] == 'menu_item_key'}.map{|e| e[:name].upcase})
        end
        if params[:tags].select{|e| e[:type] == 'area_trend'}.present?
          @locations = area_trend
        end
        if params[:tags].select{|e| e[:type] == 'price'}.present?
          @locations = price(@locations, params[:tags].select{|e| e[:type] == 'price'}.map{|e| e[:name].to_i})
        end
        @locations.uniq{|location| location.id}
      end

      def get_locations
		    # Determine the parameters

		    # Make the parameters more accessible

		    fundraiser_type_id = params[:fundraiser_type_id]
        @fundraiser_type = FundraiserType.find_by_id(params[:fundraiser_type_id])
        @locations = []
		    @fundraiser_type.locations.each do |l|
          @locations.push(Location.find(l.id))
        end
     	end

      def get_fundraisers
		    # Determine the parameters

		    # Make the parameters more accessible
		    fund_ids = params[:fundraiser_ids]
		    res = []
		    fund_ids.each do |id|
		    	fundraiser = Fundraiser.find_by_id(id)#.select(Fundraiser.column_names - ["credit_card_expiration_date", "credit_card_number","credit_card_security_code","credit_card_type"])
		    	if(fundraiser != nil)
			  	 	fund = {"fundraiser" => fundraiser, "fundraiser_types" =>fundraiser.fundraiser_types }
			    	res << fund
			    end
		    end

		    render  :json => {:fundraisers => res}

     	end

      def show
        @res_location = Location.find(params[:id])
        @res_location.contests=[]
        # @res_location.messages = Location.get_global_message(current_user.email, @res_location.id).first
        # @points = @res_location.points_awarded_for_checkin + current_user.points
        # @res_location.prizes = Prize.get_unlocked_prizes_by_location(@res_location.id, @points, current_user.id)
        contests = Contest.all
        contests.each do |c|
          if Time.parse(c.start_date) < Time.now && Time.parse(c.end_date) > Time.now
            restaurants = c.restaurants.split(",").map { |s| s.to_i }
            if restaurants.include?(@res_location.id)
              @res_location.contests.push(c)
            end
          end
        end
        @location = @res_location
      end

      def favorite
        @location = Location.find(params[:id])
        @location_favourite = LocationFavourite.where(user_id: @user.id, location_id: @location.id).first
        if params[:should_favourite] == "false"
          @location_favourite.destroy if @location_favourite.present?
        else
          lf = LocationFavourite.create(user_id: @user.id, location_id: @location.id) unless @location_favourite.present?
          if lf.present?
            return render status: 500 , json: { status: :error, error: lf.errors.full_messages } unless lf.valid?
          end
        end

        render status: 200 , json: { status: :ok, error: '' }
      end

      private

      def location(names)
        result_hash = names.inject({cities: [], states: []}) do |accumulator, name|
          split_name = name.split(',')
          accumulator[:cities].push split_name[0].strip
          accumulator[:states].push State.where(state_code: split_name[1].strip).first.name
          accumulator
        end
        Location.includes(:menus).where(city: result_hash[:cities], state: result_hash[:states], menus: {publish_status: 2}).to_a
      end

      def contest(locations, names)
        locations.reduce([]) do |res, l|
          if names.include?(l.id)
            res << l
          else
            res
          end
        end
      end

      def cuisine(locations, names)
        locations.reduce([]) do |res, l|
          if names.include?(l.primary_cuisine.try(:upcase)) ||
            names.include?(l.secondary_cuisine.try(:upcase))
            res << l
          else
            res
          end
        end
      end

      def menu_item(locations, names)
        locations.reduce([]) do |res, l|
          l_menu_locations = l.menus.reduce([]) do |res, m|
            menu_locations = m.items.reduce([]) do |res, item|
              if names.include? item.name.try(:upcase)
                res << l
              else
                res
              end
            end
            res << menu_locations
          end
          res << l_menu_locations
        end.flatten.uniq
      end

      def menu_item_key(locations, names)
        locations.reduce([]) do |res, l|
          l_menu_locations = l.menus.reduce([]) do |res, m|
            menu_locations = m.items.reduce([]) do |res, item|
              if item.item_keys.detect{ |ik| names.include? ik.name.try(:upcase) }
                res << l
              else
                res
              end
            end
            res << menu_locations
          end
          res << l_menu_locations
        end.flatten.uniq
      end

      def area_trend
        date = (DateTime.now - 3.days)
        LocationTrendingService.new(nearby_locations, date, 10).find_trending
      end

      def price(locations, names)
        locations.reduce([]) do |res, l|
          items = l.items.select{|item| item.price.to_i > 3}
          average_price = if items.size > 0
            sum = items.reduce(0) do |res, item|
              res + item.price
            end
            sum / items.count.to_f
          else
            0.0
          end
          names.each do |name|
            case average_price
            when 0..11
              res << l if name == 1
            when 11..31
              res << l if name == 2
            when 31..60
              res << l if name == 3
            else
              res << l if name == 4
            end
          end
          res
        end.flatten.uniq
      end
    end
  end
end
