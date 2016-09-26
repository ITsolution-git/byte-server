class ItemImage < ActiveRecord::Base
  include Rotatable #can be found in the /app/models/concerns directory
  include CopyCarrierwaveFile
  attr_accessible :image, :item_id, :item_token, :crop_x, :crop_y, :crop_w, :crop_h, :rate
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :rate

  belongs_to :item
  validate :image_size_validation, :if => 'image?'

  after_save :reprocess_image, :if => :cropping?
  after_destroy :remove_images_dir

  mount_uploader :image, ImageUploader

  #remove directory left after destroy
  def remove_images_dir
    #remove carrierwave uploads
    FileUtils.remove_dir("#{Rails.root}/public/uploads/item_image/image/#{id}", :force => true)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def duplicate_file(original)
    copy_carrierwave_file(original, self, :image)
    self.save!
  end

  private
    def reprocess_image
      self.image.recreate_versions!
    end

    def image_size_validation
      errors.add(:base, 'Image should be less than 4MB') if image.file.exists? && image.size > 4.megabytes
    end
end
