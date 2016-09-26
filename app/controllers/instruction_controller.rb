class InstructionController < ApplicationController
  before_filter :authorise_request_as_json
  before_filter :authorise_user_param, only: [:get_instruction_categories, :get_instruction_items]

  def get_instruction_categories
    @categories = InstructionCategory.order("created_at")
  end

  def get_instruction_items
    category_id = params[:category_id] if params[:category_id]
    check_category = InstructionCategory.where("id=?", category_id).first
    if check_category.nil?
      render :status => 404,:json=> {:status=>:failed, :error=>"Invalid Category"}
    else
      @items = InstructionItem.where("instruction_category_id=?", category_id).order("created_at")
    end
  end
  def add_instruction_category_demo

    arr = Array.new
    arr.append("My Favorites")
    arr.append("My Points")
    arr.append("My Orders")

    youtube_arr =["YpXAegWM3Ew", "LrU1wiSqKFA","fjrkRu4gyz8"]
    icon_arr =[MY_FAVOURITES, MY_POINTS, MY_ORDERS]
    j=0
    for i in arr
      a = InstructionCategory.new
      a.name= i
      a.user_id= 1
      a.icon =icon_arr[j]
      a.save
      j+=1

      b = InstructionItem.new
      b.instruction_category_id = a.id
      b.item_name = "Save "+ a.name.split(" ").last
      b.youtube_id = youtube_arr[0]
      b.times ="1:13:05"
      b.save

      b = InstructionItem.new
      b.instruction_category_id = a.id
      b.item_name = "View "+ a.name.split(" ").last
      b.youtube_id = youtube_arr[1]
      b.times ="3:07"
      b.save

      b = InstructionItem.new
      b.instruction_category_id = a.id
      b.item_name = "Share "+ a.name.split(" ").last
      b.youtube_id = youtube_arr[2]
      b.times ="7:48"
      b.save


    end
    render :json=> {:status=>"success"}
  end

  def delete_instruction_category_demo
    InstructionCategory.find_by_sql("delete from instruction_categories")
    InstructionItem.find_by_sql("delete from instruction_items")
    render :json=> {:status=>"success"}
  end
end
