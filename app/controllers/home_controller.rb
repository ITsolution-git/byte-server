class HomeController < ApplicationController
  #before_filter :authenticate_user!, :only=>:index
  layout "imenu"
  # require 'google/api_client'
  def index
    #consumer_key = 'FcoqdAKBzumDtPAmE7ehEg'
    #consumer_secret = 'U2Ko6Te21fY_xZ1aNtm7fVGOldw'
    #token = 'FmZxDCBC-_GWHlKrQW1WTEn2PKuHSiOq'
    #token_secret = 'NqJoMOTjpAiO260-9IrrJFcZDd8'
    #
    #api_host = 'api.yelp.com'
    #
    #consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
    #access_token = OAuth::AccessToken.new(consumer, token, token_secret)
    #
    #path = "/v2/search?term=food&location=new+jersey"
    #
    #p = access_token.get(path).body
    #render :json =>  p
  end

  def contact
    uri = URI.parse("http://dns-record-viewer.online-domain-tools.com/tool-form-submit/")

    # Shortcut
    response = Net::HTTP.post_form(uri, {"host" => "mymenu.us", "nameServer" => "8.8.8.8",
        'types' => 'MX', 'send' => '> Query!'})

    # Full control
    # http = Net::HTTP.new(uri.host, uri.port)

    # request = Net::HTTP::Post.new(uri.request_uri)
    # request.set_form_data({"host" => "mymenu.us", "nameServer" => "8.8.8.8",
    #     'types' => 'MX', 'send' => '> Query!'})

    # response = http.request(request)
    out = response.body.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
    result = out.scan(/<div class="results">(.*)<\/div>/m)
    if !result[0].nil? && result[0][0].to_s.match(/ASPMX.L.GOOGLE.COM/i)
      puts "@zo11"
      return true
    end
    return false
    # match = result[0][0].match(/ASPMX.L.GOOGLE.COM/i)
    # puts "@out5", match
    # user = User.find(5)
    # location = Location.find(2)
    # owner_id = location.owner.id
    # # group = ContactGroup.find_by_title(FAVORITE_GROUP)

    # # redirect to authorize url if have no access token
    # # url = oauth_client_url(owner_id)
    # # return redirect_to url if url

    # user.first_name = "Smart 20"
    # save_contact(owner_id, user, FAVORITE_GROUP, SHARE_MENU_ITEMS_GROUP, RATE_GROUP)
    # @data = api_client(owner_id).all
  end

  # def oauth2callback
  #   puts "@auth_client_obj", @auth_client_obj.auth_code.inspect
  #   access_token_obj = @auth_client_obj.auth_code.get_token(params[:code], { :redirect_uri => ENV['REDIRECT_URL'], :token_method => :post })
  #   session[:access_token] = access_token_obj.token
  #   session[:refresh_token] = access_token_obj.refresh_token
  #   redirect_to contact_path
  #   # session[:expires_in] =
  #   # puts "@access_token smart: ", access_token_obj.inspect
  #   # puts "Token is: #{access_token_obj.token}"
  #   # puts "Refresh token is: #{access_token_obj.refresh_token}"
  #   # puts "\n\n\nNow you can make API requests with the following api_access_token_obj variable!\n"
  #   # puts "api_client_obj = OAuth2::Client.new(client_id, client_secret, {:site => 'https://www.googleapis.com'})"
  #   # puts "api_access_token_obj = OAuth2::AccessToken.new(api_client_obj, '#{access_token_obj.token}')"
  #   # puts "api_access_token_obj.get('some_relative_path_here') OR in your browser: http://www.googleapis.com/some_relative_path_here?access_token=#{access_token_obj.token}"
  #   # puts "\n\n... and when that access_token expires in 1 hour, use this to refresh it:\n"
  #   # puts "refresh_client_obj = OAuth2::Client.new(client_id, client_secret, {:site => 'https://accounts.google.com', :authorize_url => '/o/oauth2/auth', :token_url => '/o/oauth2/token'})"
  #   # puts "refresh_access_token_obj = OAuth2::AccessToken.new(refresh_client_obj, '#{access_token_obj.token}', {refresh_token: '#{access_token_obj.refresh_token}'})"
  #   # puts "refresh_access_token_obj.refresh!"
  # end

  def about
    @page =   Page.find_by_name("About")
  end
  def products
    @page = Page.find_by_name("Product")
  end
  def checkout
    @page = Page.find_by_name("Checkout")
  end
  def contact_us
    @page = Page.find_by_name("Contact")
  end
  def faqs
    @page = Page.find_by_name("Faq")
  end
end
