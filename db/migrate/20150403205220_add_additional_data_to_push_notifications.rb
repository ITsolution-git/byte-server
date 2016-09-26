class AddAdditionalDataToPushNotifications < ActiveRecord::Migration
  def change
    # NOTE: There is a risk this data is not worth the space it could consume.
    # Its primary value is for debugging purposes.
    add_column :push_notifications, :additional_data, :text
  end
end
