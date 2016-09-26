require 'RMagick'
include Magick
module Rotatable
  extend ActiveSupport::Concern
  included do
    def rotate
      url = self.image.current_path
      images = Image.read url
      images.each do |image|
        image.rotate! 90
        image.write url
      end
      self.image.recreate_versions!
    end
  end
end
