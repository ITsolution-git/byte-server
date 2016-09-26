class ServerAvatar < ActiveRecord::Base
  include Rotatable #can be found in the /app/models/concerns directory
  attr_accessible :image, :server_id, :server_token, :crop_x, :crop_y, :crop_w, :crop_h, :rate
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :rate

  belongs_to :server
  mount_uploader :image, AvatarUploader
  after_save :reprocess_image, :if => :cropping?

  #remove directory left after destroy
  after_destroy :remove_images_dir
  def remove_images_dir
    #remove carrierwave uploads
    FileUtils.remove_dir("#{Rails.root}/public/uploads/server_avatar/image/#{id}", :force => true)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private
    def reprocess_image
      self.image.recreate_versions!
    end
end
