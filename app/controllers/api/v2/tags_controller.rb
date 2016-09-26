module Api
  module V2
    class TagsController < Api::BaseController
      skip_before_filter :authenticate_user
      respond_to :json

      def index
        # location_tags   0.7s
        # cuisine_tags    2.5s
        # menu_item_keys  19s -> 2.5s
        # price_tag       8.5s -> 3.5s
        # menu_item_tags  19s -> 2.5s
        # area_trend      0.3s

        # total time      40s -> 5.5s

        @tags = [location_tags, cuisine_tags, menu_item_keys, price_tag, menu_item_tags, area_trend]
      end

      def show
        item_tag = ItemTag.new(params[:id])
        render json: {tag_categories: item_tag.tag_kinds}
      end

      def cronweeklyreport
        @restaurants = Location.where(weekly_progress_report: 1)

        @restaurants.each do |restaurant|
            @menu_items = restaurant.items
            @prizes = Prize.where(status_prize_id: restaurant.status_prizes.pluck(:id))


            @checkins = restaurant.checkins.includes(:user)
            @socials = restaurant.social_shares
            @item_ids = params[:item_id].present? ? [params[:item_id]] : restaurant.items.pluck(:id)
            @prize_ids = params[:prize_id].present? ? [params[:prize_id]] : @prizes.pluck(:id)
            @comments = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids})

            @new_ids = @checkins.select('min(id)').group(:user_id)
            @new_customers = @checkins.where(id: @new_ids)
            @returning_customers = @checkins.where("id NOT IN (?)", @new_ids.pluck(:id))

            period = 1
            @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
            @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_day('item_favourites.created_at', range: period.weeks.ago..(period-1).weeks.ago).count
            @order_count = OrderItem.where(item_id: @item_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
            @social_count = @socials.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
            @new_customer_count = @new_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
            @returning_customer_count = @returning_customers.group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
            @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_day(:created_at, range: period.weeks.ago..(period-1).weeks.ago).count
            @feedback_rating = @comments.group_by_day('item_comments.created_at', range: period.weeks.ago..(period-1).weeks.ago).group(:rating).count

            @feedback_rating_sum = 0
            @feedback_rating_count = 0
            @feedback_rating.each do |(date, rating), count|
              @feedback_rating_sum += rating * count
              @feedback_rating_count += count
            end

            @feedback_rating_str="A+"
            if @feedback_rating_count > 0
              @feedback_rating = (@feedback_rating_sum / @feedback_rating_count).floor
              case @feedback_rating
              when 1.0
                @feedback_rating_str = "A+"
              when 2.0
                @feedback_rating_str = "A"
              when 3.0
                @feedback_rating_str = "A-"
              when 4.0
                @feedback_rating_str = "B+"
              when 5.0
                @feedback_rating_str = "B"
              when 6.0
                @feedback_rating_str = "B-"
              when 7.0
                @feedback_rating_str = "C+"
              when 8.0
                @feedback_rating_str = "C"
              when 9.0
                @feedback_rating_str = "C-"
              when 10.0
                @feedback_rating_str = "D+"
              when 11.0
                @feedback_rating_str = "D"
              when 12.0
                @feedback_rating_str = "D-"
              when 13.0
                @feedback_rating_str = "F"
              else
                @feedback_rating_str = " "
              end
            end

            @week = {
              :feedback_count => @feedback_count.map { |k, v| v }.sum,
              :favourite_count => @favourite_count.map { |k, v| v }.sum,
              :order_count => @order_count.map { |k, v| v }.sum,
              :social_count => @social_count.map { |k, v| v }.sum,
              :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
              :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
              :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum,
              :feedback_rating => @feedback_rating_str
            }

            @feedback_count = ItemComment.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_comments.created_at', range: period.years.ago..(period-1).years.ago).count
            @favourite_count = ItemFavourite.joins(:build_menu).where(build_menus: {item_id: @item_ids}).group_by_week('item_favourites.created_at', range: period.years.ago..(period-1).years.ago).count
            @order_count = OrderItem.where(item_id: @item_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
            @social_count = @socials.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
            @new_customer_count = @new_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
            @returning_customer_count = @returning_customers.group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count
            @redeemed_prize_count = PrizeRedeem.where(prize_id: @prize_ids).group_by_week(:created_at, range: period.years.ago..(period-1).years.ago).count

            @year = {
              :feedback_count => @feedback_count.map { |k, v| v }.sum,
              :favourite_count => @favourite_count.map { |k, v| v }.sum,
              :order_count => @order_count.map { |k, v| v }.sum,
              :social_count => @social_count.map { |k, v| v }.sum,
              :new_customer_count => @new_customer_count.map { |k, v| v }.sum,
              :returning_customer_count => @returning_customer_count.map { |k, v| v }.sum,
              :redeemed_prize_count => @redeemed_prize_count.map { |k, v| v }.sum
            }

            UserMailer.send_email_weekly_report(restaurant.weekly_progress_email, restaurant, @week, @year).deliver
        end
        render status: 200, json: { status: :success }
      end

      def find_by_position
        lat = params[:lat]
        lng = params[:lng]
        @profiles = UserProfile.all
        results = []
        @profiles.each do |p|
          @publish_timestamp = 0
          if p.publish_date.present? and p.publish_date !=""
            @publish = p.publish_date.split(" | ")
            @publish_date = @publish[0].split('.')
            @publish_timestamp = DateTime.parse(@publish_date[2]+"-"+@publish_date[1]+"-"+@publish_date[0]+" "+@publish[1]+":00").to_i
          end
          @unpublish_timestamp = 0
          if p.unpublish_date.present? and p.unpublish_date != ""
            @unpublish = p.unpublish_date.split(" | ")
            @unpublish_date = @unpublish[0].split('.')
            @unpublish_timestamp = DateTime.parse(@unpublish_date[2]+"-"+@unpublish_date[1]+"-"+@unpublish_date[0]+" "+@unpublish[1]+":00").to_i
          end
          if Geocoder::Calculations.distance_between([lat, lng], [p.latitude.to_f, p.longitude.to_f]) < p.radius.to_f and @publish_timestamp  > @unpublish_timestamp
            if p[:tags].present?
              p[:tags] = p[:tags].split(",").map { |s| s.to_i }
              @tags = []
              p[:tags].each do |t|
                if p[:show_type] == "restaurant"
                  @tag = CuisineType.find(t)
                  @tags.push(@tag[:name])
                elsif p[:show_type] == "menuitem"
                  @key = ItemKey.find(t)
                  @tags.push(@key[:name])
                end
              end
              p[:tags_string] = @tags
            end
            results.push(p)
          end
        end
        render json: results
      end

      private

      # def menu_items
      #
      #   @_menu_items ||= nearby_locations.map{|l| l.menus.map{|m| m.items}}.flatten.compact
      #   @_menu_items
      #
      #   # Item.where( :location_id => nearby_locations.map{ | l | l.id } )  # returns slightly different results (may be more accurate, but leaving this alone for now, as it isn't used anymore anyway)
      # end

      def location_tags
        {
          name: 'Locations',
          tag_type: 'location',
          sequence: '1',
          tags: filtered_locations_tags
        }
      end

      def filtered_locations_tags
        # Returns an array of strings
        all_tags = Location.includes(:menus).where(menus: {publish_status: 2}).map{|l| l.try(:short_address)}.compact.map{|name| name.upcase}.uniq.sort

        # Filter all tags to only include TEXAS and ARKANSAS
        filtered_tags = []
        all_tags.each do |tag_string|
          # if tag_string.include?("TEXAS") || tag_string.include?("ARKANSAS")
            parsed_tag = tag_string.split(',')
            city = parsed_tag[0].strip
            if State.where('name = ? OR state_code = ?', parsed_tag[1].strip, parsed_tag[1].strip).first.present?
              state = State.where('name = ? OR state_code = ?', parsed_tag[1].strip, parsed_tag[1].strip).first.state_code
              filtered_tags << city + ', ' + state
            end
          # end
        end

        return filtered_tags
      end

      def cuisine_tags
        tags = nearby_locations.reduce([]) do |res, l|
          res << l.try(:primary_cuisine) << l.try(:secondary_cuisine)
        end.compact.uniq

        {
          name: 'Restaurant Cuisine',
          tag_type: 'cuisine',
          sequence: '3',
          tags: tags.map{|tag| tag.upcase}
        }
      end

      def menu_item_tags
        # tags =  menu_items.reduce([]){ |res, i| res << i.tags }.flatten.compact.map{|tag| tag.name.upcase }.uniq

        # because tags table in currently empty, it may well be unused

        if Tag.count == 0
          tags = []
        else
          location_ids = nearby_locations.map{|l| l.id}
          tags = Tag.select( :name ).where( :id => Tagging.select( :tag_id ).where( :taggable_id => Item.select( :id ).where( :location_id => location_ids ) ) ).flatten.compact.map{ | tag | tag.name.upcase }.uniq
        end

        {
          name: 'Menu Item Tags',
          tag_type: 'menu_item',
          sequence: '6',
          tags: tags
        }
      end

      def menu_item_keys

        # tags = menu_items.reduce([]){ |res, i| res << i.item_keys }.flatten.compact.map{|tag| tag.name.upcase }.uniq

        location_ids = nearby_locations.map{|l| l.id}
        tags = ItemKey.select( :name ).where( :id => ItemItemKey.select( :item_key_id ).where( :item_id => Item.select( :id ).where( :location_id => location_ids ) ) ).flatten.compact.map{ | tag | tag.name.upcase }.uniq

        {
          name: 'Menu Keys',
          tag_type: 'menu_item_key',
          sequence: '4',
          tags: tags
        }
      end

      def area_trend
        {
          name: 'Trending Restaurants',
          tag_type: 'area_trend',
          sequence: '2',
          tags: ['TRENDING']
        }
      end

      def price_tag

        # tags = nearby_locations.reduce([]) do |res, l|
        #   menus_i_tags = l.menus.reduce(0) do |res, m|
        #     m_i_tags = m.items.reduce(0) do |res, i|
        #       if i.drink?
        #         res += i.price
        #       else
        #         res
        #       end
        #     end
        #     if m.items.count > 0
        #       res += m_i_tags.to_f / m.items.count
        #     else
        #       res
        #     end
        #   end
        #   case menus_i_tags
        #   when 0..11
        #     res.push(1)
        #   when 11..31
        #     res.push(2)
        #   when 31..60
        #     res.push(3)
        #   else
        #     res.push(4)
        #   end
        #   res
        # end.sort.uniq

        # the following takes advantage of fact that all menu items return true for drink?

        location_ids = nearby_locations.map{|l| l.id}
        tags = []

        Menu.select( :id ).where( :location_id => location_ids ).each do | menu |
          case menu.items.average( :price )
            when 0..11
              tags.push( 1 )
            when 11..31
              tags.push( 2 )
            when 31..60
              tags.push( 3 )
            else
              if menu.items.count > 0
                tags.push( 4 )
              end
          end
        end

        {
          name: 'Price',
          tag_type: 'price',
          sequence: '5',
          tags: tags.sort.uniq
        }
      end
    end
  end
end
