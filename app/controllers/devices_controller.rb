class DevicesController < ApplicationController
  before_filter :authenticate_user_json

  # def create
  #   # @device = Device.find_by_token(params[:device_token])
    
  #   # # Create/complete the device record if necessary
  #   # if !@device
  #   #   @device = Device.new(user_id: @user.id, token: params[:device_token], operating_system: params[:device_type])
  #   #   if !@device.save
  #   #     return render status: 422, json: {status: 'failed', errors: @device.errors.full_messages.join(', ') }
  #   #   end
  #   # elsif !@device.parse_installation_id # this isn't strictly necessary, but the Parse ID is a critical value
  #   #   @device.create_parse_installation_record
  #   # end

  #   return render({json: {status: 'success'}, status: :ok})
  # end

end
