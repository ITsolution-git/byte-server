module ApplicationHelper
  def nav_pill_active(path)
    "active" if current_page?(path)
  end

  def full_title(page_title)
    base_title = 'Intelligent-menu'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def load_content_of_file(path)
    file_path = File.join(Rails.root, path)
    file = File.open(file_path,"rb")
    file.read
  end

  def load_toogle_icon(object)
    toogle_icon = 'icon-minus btn togglebtn'
    if object.new_record?
      toogle_icon = 'icon-plus btn togglebtn'
    end
    return toogle_icon
  end

  def toogle_state(object)
    return 'in' if not object.new_record?
  end

  def restaurants_total_amount
    current_user.restaurants.size*current_user.try(:price).try(:plan).try(:name).to_i rescue 0
  end

  def split_day(day)
    day.gsub("-","").gsub(" ","").split("\n") unless day.blank?
  end

  def flash_class_name(name)
    case name
      when :notice then 'info'
      when :success then 'success'
      when :error then 'danger'
    else
      'warning'
    end
  end
end
