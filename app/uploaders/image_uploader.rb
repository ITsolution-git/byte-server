class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  Rails.env.test? || Rails.env.development? ? (storage :file) : (storage :fog)

  version :primary do
    process :scale_image
    process :crop
  end

  version :thumb do
    process :scale_image
    process :resize_to_fill => [160, 160]
  end

  def store_dir
    "#{Rails.env}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # My piet optimize recipe
  # def optimize
  #   manipulate! do |img|
  #     Piet.optimize(current_path, :quality => 0)
  #     img
  #   end
  # end

  # def scale_image
  #   array_width_height = []
  #   img = ::Magick::Image::read(model.send(mounted_as).path).last
  #   if model
  #     array_width_height = [img.columns, img.rows]
  #   end
  #   if !array_width_height.empty?
  #     width_image = array_width_height[0].to_i
  #     height_image = array_width_height[1].to_i
  #     # puts "width_image : #{width_image} and height_image : #{height_image}"
  #     if width_image > 1024 && height_image > 768
  #        resize_to_fill(1024, 768)
  #     elsif width_image > 1024 && height_image <= 768
  #        resize_to_fill(1024, height_image)
  #     elsif width_image <= 1024 && height_image > 768
  #        resize_to_fill(width_image, 768)
  #     end
  #   end
  # end

  def scale_image
    array_width_height = []
    img = ::Magick::Image::read(model.send(mounted_as).path).last
    if model
      array_width_height = [img.columns, img.rows]
    end
    if !array_width_height.empty?
      width_image = array_width_height[0]
      height_image = array_width_height[1]

      rate = 1
      rate_height = 0
      rate_width = 0
      if (height_image > 1024 || width_image > 768)
        rate_height = height_image.to_f / 1024
        rate_width = width_image.to_f / 768
        if rate_width > rate_height
          rate = rate_width
        else
          rate = rate_height
        end
        height_image = height_image.to_f / rate.to_f
        width_image = width_image.to_f / rate.to_f
        resize_to_fill(width_image.to_i, height_image.to_i)
      end
      # puts "width_image : #{width_image} and height_image : #{height_image}"

      # if width_image > 1024 && height_image > 768
      #    #resize_to_fill(1024, 768)
      # elsif width_image > 1024 && height_image <= 768
      #    resize_to_fill(1024, height_image)
      # elsif width_image <= 1024 && height_image > 768
      #    resize_to_fill(width_image, 768)
      # end
    end
  end

  def resize_to_fill(width, height, filter=::Magick::LanczosFilter)
    manipulate! do |img|
      img.resize!(width, height, filter)
      img = yield(img) if block_given?
      img
    end
  end

  def image
    begin
      if original_filename.present? && File.extname(original_filename) == '.png'
        image = PngQuantizator::Image.new(model.send(mounted_as).path)
        image.quantize_to(model.send(mounted_as).path)
      else
      # image.quantize!
        Piet.optimize(model.send(mounted_as).path, :quality => 50)
      end
      @image ||= ::Magick::Image::read(model.send(mounted_as).path).first
    rescue
      @image = nil
    end
  end

  def width
    return image.nil? ? 0 : image.columns
  end

  def height
    return image.nil? ? 0 : image.rows
  end

  # def filename
  #   super.chomp(File.extname(super)) + '.jpg' if original_filename.present?
  # end


  # Quantize image
  # def quantize_image
  #   image ||= PngQuantizator::Image.new(model.send(mounted_as).path)
  #   #Quantize to a new file
  #   image.quantize_to(model.send(mounted_as).path)
  #   #Quantize in place
  #   image.quantize!
  # end

  # Execute the Crop
  def crop
    return unless model.cropping?

    manipulate! do |img|
      if original_filename.present? && File.extname(original_filename) == '.png'
        image_png = PngQuantizator::Image.new(model.send(mounted_as).path)
        image_png.quantize_to(model.send(mounted_as).path)
      else
        Piet.optimize(model.send(mounted_as).path, :quality => 50)
      end
      image ||= ::Magick::Image::read(model.send(mounted_as).path).first
      x = model.crop_x.to_i * (model.rate.to_f)
      y = model.crop_y.to_i * model.rate.to_f
      w = model.crop_w.to_i * model.rate.to_f
      h = model.crop_h.to_i * model.rate.to_f
      image.crop!(x.to_i, y.to_i, w.to_i, h.to_i)
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
     %w(gif bmp jpeg tiff max png jpg)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
