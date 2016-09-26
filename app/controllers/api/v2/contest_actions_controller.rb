module Api
  module V2
    class ContestActionsController < Api::BaseController
      respond_to :json

      def create
        location = Location.find(params[:location_id])
        return render status: 404, json: { status: :failed, error: 'Resource not found' } unless location.present?

        @check_action = ContestAction.where("contest_id=? and location_id=? and user_id=? and item_id=? and item_name=? and created_at >= ?", params[:contest_id], params[:location_id], current_user.id, params[:item_id], params[:item_name], Time.now.beginning_of_day)
        if @check_action.present?
          render status: 200, json: { status: :failed, error: 'You can only submit one photo per menu item per day.' }
        else
          @today_actions = ContestAction.where("contest_id=? and user_id=? and created_at >= ?", params[:contest_id], current_user.id, Time.now.beginning_of_day)
          if @today_actions.count < 20
            @contest_action = ContestAction.new
            @contest_action.user_id = current_user.id
            @contest_action.location_id = location.id
            @contest_action.contest_id = params[:contest_id]
            if params[:item_id].present?
                @contest_action.item_id = params[:item_id]
            end
            @contest_action.item_name = params[:item_name]
            @contest_action.photo_url = URI.decode(params[:photo_url])
            @contest_action.status="Pending"

            if @contest_action.save
              @contest_action.photo_url = @contest_action.photo_url.gsub("+","%2B")
              render status: 200, json: { status: :success, contest_action_data: @contest_action }
            else
              render status: 404, json: { status: :failed, error: 'Server Error' }
            end
          else
            render status: 200, json: { status: :failed, error: 'You can submit 3 menu items entries per day.' }
          end
        end
      end

      def contest_image
        #render status:200, json: {time: Time.now.to_i}
        # photo_hash = Cloudinary::Uploader.upload(params[:contest],
        #                             folder: "users/"+Time.now.to_i.to_s+"#{current_user.id}",
        #                             public_id: "user_contest_"+Time.now.to_i.to_s+"#{current_user.id}",
        #                             overwrite: true)
        # if photo_hash.present?
        #   @photo = Photo.new
        #
        #   @photo.public_id = photo_hash["public_id"];
        #   @photo.format = photo_hash["format"];
        #   @photo.version = photo_hash["version"];
        #   @photo.width = photo_hash["width"];
        #   @photo.height = photo_hash["height"];
        #   @photo.resource_type = photo_hash["resource_type"];
        #   @photo.photoable_type = "Contest";
        #   @photo.name = current_user.username + "_" + current_user.id.to_s
        #
        #   if @photo.save
        #     render status: 200, json: { status: :success, image: @photo.fullpath }
        #   else
        #     render status: 404, json: { status: :failed, error: 'Server Error' }
        #   end
        # else
        #   render status: 404, json: { status: :failed, error: 'Server Error' }
        # end
        contest = Contest.find(params[:contest_id])
        return render status: 200, json: { status: :failed, error: 'Contest should be required' } unless contest.present?

        location = Location.find(params[:location_id])
        return render status: 200, json: { status: :failed, error: 'Location should be required' } unless location.present?

        @key_string = contest.name+"/pending/"+location.name+"_"+current_user.username+"_"+Time.now.to_i.to_s+".jpg"

        image = StorageBucket.files.new(
          key: @key_string.tr(" ","+"),
          body: params[:contest],
          public: true
        )

        image.content_type = 'image/jpeg'
        image.acl = 'public-read'
        image.cache_control = 'public,max-age=3600'
        image.content_disposition = 'inline'
        image.public = true

        image.save

#              @contest_action.photo_url = @contest_action.photo_url.gsub("+","%2B")
        public_url = image.public_url.gsub("+","%2B")

        render status: 200, json: { status: :success, image: public_url }
      end
      def check_contest_location
        #render status:200, json: {time: Time.now.to_i}

        location = Location.find(params[:location_id])
        return render status: 404, json: { status: :failed, error: 'Resource not found' } unless location.present?

        @contests = Contest.all
        @res_contests = []
        @contests.each do |c|
          if Time.parse(c.start_date) < Time.now && Time.parse(c.end_date) > Time.now
            @restaurants = c.restaurants.split(",").map { |s| s.to_i }
            if @restaurants.include?(location.id)
              @res_contests.push(c)
            end
          end
        end
        render status:200, json: {contests: @res_contests}
      end
      def update_contest_action
        if params[:type].present? && params[:contest_action_id].present?
          @contest_action = ContestAction.find(params[:contest_action_id])

          case params[:type]
          when "Facebook"
            action_attributes = {
              facebook: 1
            }
          when "Twitter"
            action_attributes = {
              twitter: 1
            }
          when "Instagram"
            action_attributes = {
              instagram: 1
            }
          when "Grade"
            action_attributes = {
              grade: params[:grade],
              comment: params[:comment]
            }
          end

          @contest_action.update_attributes(action_attributes)
          @contest_action.photo_url = @contest_action.photo_url.gsub("+","%2B")
          render status: 200, json: { status: "success", contest_action: @contest_action}
        else
          render status: 404, json: { status: :failed, error: 'Parameter Error' }
        end
      end
    end
  end
end
