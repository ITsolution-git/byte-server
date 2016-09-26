class LocationImage < ActiveRecord::Base #These are the restaurant profile pictures
  require 'file_size_validator'
  include Rotatable
  mount_uploader :image, ImageUploader
  belongs_to :location

  validates :image, presence: true, file_size: { maximum: 4.0.megabytes.to_i }

  default_scope order('location_images.index ASC')
  after_save :reprocess_image, :if => :cropping?
  after_destroy :remove_images_dir #remove directory left after destroy

  attr_accessible :image, :location_id, :crop_x, :crop_y, :crop_w, :crop_h, :rate, :index, :location_token
  attr_accessor :ver, :crop_x, :crop_y, :crop_w, :crop_h, :rate

  def remove_images_dir
    #remove carrierwave uploads
    FileUtils.remove_dir("#{Rails.root}/public/uploads/location_image/image/#{id}", :force => true)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private
    def reprocess_image
      self.image.recreate_versions!
    end

end
