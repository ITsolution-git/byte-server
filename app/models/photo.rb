class Photo < ActiveRecord::Base
  before_destroy :destroy_cloud_photo
  attr_accessible :id, :crop_x, :crop_y, :crop_w, :crop_h, :angle, :public_id, :version, :format, :resource_type, :height, :width, :rate, :name

  def destroy_cloud_photo
    Cloudinary::Uploader.destroy(public_id) if public_id
  end

  def path(custom_format=nil)
    p = "v#{version}/#{public_id}"
    if resource_type == 'image' && custom_format != false
      custom_format ||= format
      p<< ".#{custom_format}"
    end
    p
  end

  def fullpath(options={})
    if options.has_key?(:format)
      format = options.delete(:format)
    else
      format = 'png'
    end
    options = options.reverse_merge(resource_type: resource_type)
    Cloudinary::Utils.cloudinary_url(path(format), {transformation: transformations(options)})
  end
  alias_method :url, :fullpath

  def logopath
    Cloudinary::Utils.cloudinary_url(path("png"), {transformation: [
        {x: (crop_x if crop_x), y: (crop_y if crop_y), width: (crop_w if crop_w), height: (crop_h if crop_h), crop: :crop},
        {width: (180), height: (180 ), crop: ('fit')},
        {angle: angle}]} )
    end

  def transformations(options)
    crop_attributes = cropped? ? {x: crop_x, y: crop_y, width: crop_w, height: crop_h, crop: :crop} : nil
    angle_attributes = angle.present? ? {angle: angle} : nil
    [crop_attributes, angle_attributes, options].compact
  end

  def cropped?
    (crop_x.present? || crop_y.present?) && (crop_w.present? || crop_h.present?)
  end
end
