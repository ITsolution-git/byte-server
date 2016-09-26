class ItemKeyImage < ActiveRecord::Base
  include Rotatable
  include CopyCarrierwaveFile
  attr_accessible :image, :item_key_id, :item_key_token, :crop_x, :crop_y, :crop_w, :crop_h, :rate
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :rate

  belongs_to :item_key
  mount_uploader :image, MenukeyUploader
  after_save :reprocess_image, :if => :cropping?

  #remove directory left after destroy
  after_destroy :remove_images_dir
  def remove_images_dir
    #remove carrierwave uploads
    FileUtils.remove_dir("#{Rails.root}/public/uploads/item_key_image/image/#{id}", :force => true)
  end

  def duplicate_file(original)
    copy_carrierwave_file(original, self, :image)
    self.save!
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  private
    def reprocess_image
      self.image.recreate_versions!
    end
end
