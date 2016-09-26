module ItemsHelper
  def full_image_url(image)
    if Rails.env.development?
      "#{request.protocol}#{request.host.present? ? request.host + ':' : '' }#{request.port}#{image.image.url}" || ''
    else
      image.image.url
    end
  end
end
