module NotificationHelper

  def is_a_valid_email?(email)
    email = email.to_s
    return false if email.count('@') != 1
    return true if email =~ /^.*@.*(.com|.org|.net|.edu|.la|.us)$/
    return false
  end

  def val_width_height(image_size)
    ((image_size == 0) ? 1 : image_size)
  end

end
