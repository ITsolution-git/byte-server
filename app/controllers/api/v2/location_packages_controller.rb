module Api
  module V2
    class LocationPackagesController < Api::BaseController
      respond_to :json

      def show
        location = Location.where(id: params[:id]).first
        return render status: 404, json: { status: :failed, error: 'Resource not found' } unless location.present?

        location_packages = location.subscriptions.map(&:subscription_id)
        @packages = SubscriptionFetcher.new(location_packages).subscriptions
        render status: 200, json: @packages
      end
    end
  end
end
