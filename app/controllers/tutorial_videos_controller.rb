class TutorialVideosController < ApplicationController
  before_filter :check_admin, :find_video


  def edit
  end

  def update
    urlString = params[:tutorial_video][:url]
    urlString.gsub!("watch?v=", "embed/")
    @tutorialVid.update_attribute(:url, urlString)
    flash[:notice] = 'Video URL successfully saved!'
    redirect_to root_url
  end
  
  private
  def check_admin
    redirect_to root_url unless current_user.admin?
  end
  
  def find_video
    @tutorialVid = TutorialVideo.find(params[:id])
  end
end
