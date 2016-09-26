class LocationLogo < ActiveRecord::Base
  #require 'file_size_validator'
  include Rotatable
  attr_accessible :image, :location_id, :location_token, :crop_x, :crop_y, :crop_w, :crop_h, :rate
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :rate

  belongs_to :location
  mount_uploader :image, LogoUploader
  after_save :reprocess_image, :if => :cropping?
  #remove directory left after destroy
  after_destroy :remove_images_dir
  def remove_images_dir
    #remove carrierwave uploads
    FileUtils.remove_dir("#{Rails.root}/public/uploads/location_logo/image/#{id}", :force => true)
  end

  validates :image, 
    :file_size => { 
      :maximum => 6.0.megabytes.to_i
    }

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private
    def reprocess_image
      self.image.recreate_versions!
    end
end
