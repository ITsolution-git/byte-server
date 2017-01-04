
Imenu::Application.routes.draw do

  devise_for :users, :path => '', :path_names => {:sign_in => 'login', :sign_out => 'logout'},
      :controller => {':unlock'=>"points"}, :skip => [:registrations] do
    get '/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put '/' => 'registrations#update'
    delete '/' => 'devise/registrations#destroy'
    get '/cancel' => 'devise/registrations#cancel'

    post 'register/cashier' => 'registrations#create_cashier', :as => 'register_cashier'

    post '/register/setup' => 'registrations#setup_account', :as => 'setup_account'
    get '/services' => 'registrations#index', :as => 'index_user_registration'
    get '/service/:id' => 'registrations#service', :as => 'service_user_registration'
    get '/register' => 'registrations#new', :as => 'new_user_registration'
    delete '/deactive-account' => 'registrations#deactive_account', :as => 'deactive_account'

    post '/' => 'registrations#create', :as => 'user_registration'
    put '/password' => 'passwords#update', :as => 'user_password'
  end

  #wizdard user_step
  get 'user_steps/confirmation' => 'user_steps#confirmation'
  resources :user_steps

  ### API
  namespace :api, defaults: { format: :json } do
    namespace :v2 do
      resources :location_packages, only: [ :show ]
      resources :cuisine_type, only: [:show]
      resources :tags, only: [:index, :show]
      resources :locations, only: [:create, :show]
      resources :favorites, only: [:index]
      resources :orders, only: [:index]
      resources :contest_actions, only: [:create]
      post 'get_fundraisers', to: 'fundraisers#get_fundraisers'
      post 'get_restaurants', to: 'fundraisers#get_restaurants'
      post 'orders/:id/remove_order', to: 'orders#remove_order'

      post 'locations/:id/favorite/:should_favourite', to: 'locations#favorite'
      get 'menu_items/:location_id/:item_id', to: 'menu_items#show'
      get 'menu_items/:location_id', to: 'menu_items#get_all_menuitems'
      post 'menu_items/:location_id', to: 'menu_items#find_by_tag'
      get 'cronweeklyreport', to: 'tags#cronweeklyreport'
      post 'menu_profiles', to: 'tags#find_by_position'
      get 'comments/:location_id/:page_num', to: 'ratings#index'
      get 'comments/:location_id', to: 'ratings#index'
      get 'notifications/:location_id', to: 'locations#notifications'
      post "contest_image", to: 'contest_actions#contest_image'
      post "update_contest_action", to: 'contest_actions#update_contest_action'
      post "check_contest_location", to: 'contest_actions#check_contest_location'
      resources :ratings, only: [:show, :index] do
        get ':item_id', to: 'item_ratings#show', as: :item_ratings
        get ':item_id/:page_num', to: 'item_ratings#index', as: :item_ratings
        post ':item_id', to: 'item_ratings#create', as: :item_ratings
      end
      resources :prizes, only: [:index]
      resources :rewards, only: [:index] do
        collection do
          post 'redeem'
        end
        member do
          get 'scan'
          post 'redeem_code'
        end
      end
    end
  end
  ###

  #mount Ckeditor::Engine => '/ckeditor'
  mount RedactorRails::Engine => '/redactor_rails'

  # mount Resque engine web interface
  mount Resque::Server, at: '/resque'

  match '/test_send_email', to: 'invited#test_send_email', via: 'get'

  match '/invite-friend/:token', to: 'invited#new', via: 'get'
  match '/invite-social/:id/:username', to: 'invited#new_social', via: 'get'
  match '/invite-friend-share/:id/:token', to: 'invited#new_sharepoint', via: 'get'

  match '/share-item/:token/:item_id', to: 'points#share_menu_item', via: 'get'

  match '/message_global', to: 'notification#get_global_message', via: 'get'
  match '/message_restaurant', to: 'notification#get_restaurant_message', via: 'get'
  match '/get_message', to: 'notification#get_message', via: 'get'
  match '/get_detail_message', to: 'notification#get_detail_message', via: 'get'
  match '/get_unread_by_chain', to: 'notification#get_unread_by_chain', via: 'get'

  match '/delete_message_by_restaurant', to: 'notification#delete_message_by_restaurant', via: 'post'
  match '/delete_message', to: 'notification#delete_message', via: 'post'

  match '/order_build_menu', to: 'menus#order_build_menu', via: 'post', as: 'order_build_menu'

  #Favourite
  match '/favourite_global', to: 'locations#favourite_global', via: 'get'
  match '/favourite_restaurant', to: 'locations#favourite_restaurant', via: 'get'
  match '/favourite_items', to: 'locations#favourite_items', via: 'get'
  #match '/favourite_item_detail/:token/:item_id', to: 'locations#favourite_item_detail', via: 'get'

  #match '/new_form', to: 'invited#new_form', via: 'get', :as => 'new_form'

  match '/friend_regis/:access_token', to: 'invited#friend_regis', via: 'post'
  #match '/friend_regis_sharepoint/:access_token', to: 'invited#friend_regis_sharepoint', via: 'post'
  match '/regis_sharepoint/:access_token', to: 'invited#regis_sharepoint', via: 'post', as: 'regis_sharepoint'
  match '/regis_sharepoint_new', to: 'invited#regis_sharepoint_new', via: 'post'
  match '/friend_expired/:friendship_id', to: 'invited#friend_expired', via: 'get', as: 'friend_expired'
  match '/check_manager', to: 'invited#check_manager', via: 'post', as: 'check_manager'
  match '/request_friend', to: 'invited#request_friend', via: 'post', as: 'request_friend'
  match '/share_prize/:id/:token/:friendship_token', to: 'prize#new', via: 'get'
  match '/addPrize', to: 'prize#addPrize', via: 'get', as: 'addPrize'

   # match 'csv' => 'points#export_csv', :as => :csv, via:'post'
  match '/delete_user_manager/:id', to: 'accounts#delete_user_manager', via: 'get', as: 'delete_user_manager'

  resources :photos, only: [:edit, :update]

  resources :user_accounts, except: [:destroy,:update, :create, :new , :show] do
    collection do
      get 'delete'
      post 'action_delete'
      post 'action_reset'
      get 'reset_password'
      post 'search'
      get 'search'
      get "change_user_status"
      post "change_user_password"
      post 'change_user_email'
      get "move_location_to_new_user"
      post "new_user_with_location"
      get "account_setting"
    end
  end
  resources :user_account_apps do
    collection do
      get 'delete'
      post 'action_delete'
      post 'action_reset'
      get 'reset_password'
      post 'search'
      get 'search'
      get 'suspend_customer'
      get 'un_suspend_customer'
      get 'action_un_suspend_customer'
      get 'action_suspend_customer'
    end
  end
  resources :accounts, except: [:edit, :update, :destroy] do
    collection do
      get "edit"
      get "edit_package"
      get "create_login_billing"
      get "login_billing"
      get "edit_billing"
      get "get_merchant"
      put "update_address"
      put "update_package"
      put "update_billing"
      get "canel_address"
      get "canel_package"
      get "activate_service"
      get "cancel_service"
      get "canel_billing"
      get "export_pdf"
      post "create_roles"
      post "new_login_billing"
      post "check_login_billing"
      post "reset_password"
      get "change_password"
      put "update_password"
      put "update_roles"
      get "cancel_roles"
      #get "delete_user_manager"
      get "edit_roles"
      post "upload_info_avatar"
      put "upload_info_avatar"
      put "set_user_avatar"
      get "view_restaurant"
      put "update_restaurant_acitve"
      post "rotate_info"

    end
  end

  resources :subscriptions, only: [:create, :destroy] do
    collection do
      post 'byte_package'
    end
  end

  resources :invited do
    collection do
      post "invite_sms"
      post "invite_sms_share"
      post "invite_email"
      post "invite_email_share"
      get "friend_list", :action => "friend_list"
      post "regis_social"
      post "delete_friend"
      post "add_friend"
      post "reply_friend_request"
      get "get_total_message", :action => "get_total_message_friend_invite"
      get "get_invitation", :action => "get_list_friend_invitation"
      get "change_status_message",:action => "change_status_message"
    end
  end
  get "menus/index"

  get "items/index"

  get "home/index"

  get "notification/index"

  match 'analytics' => 'restaurants#analytics', :as => :analytics
  resources :dinners do
    collection do
      get "create_new", :action =>"new"
    end
  end

  resources :order do
    collection do
      get "my_order", :action => "get_order"
      get "my_orders"
      get "view_order/:order_id", :action => "view_order", :as => 'view_order'
      get "toggle_pos/:order_id", :action => "toggle_pos", :as => 'toggle_pos'
      get "change_status/:order_id", :action => "change_status", :as => 'change_status'
      get "resend_receipt/:order_id", :action => "resend_receipt", :as => 'resend_receipt'
      post "new_order"
      post "update_item"
      post "add_update_rating_order"
      post "update_order"
      # post "pay_order" # Deprecated 2015-04-21
      get "order_global" , :action => "global_orders"
      get "order_chain", :action => "chain_orders"
      get "orders" , :action => "location_orders"
      post "add_server"
      post "server_rating"
      post "edit_server_rating"
      post "server_favourite"
      get "get_server_comments"
      post "get_amount_items"
      # order and pay version 1
      post "new_order_v1"
      post "update_item_v1"
      post "update_order_v1"
      get "my_order_v1", :action => "get_order_v1"
      get "my_order_history", :action => "my_order_history"
      post "get_amount_items_v1"
      # post "pay_order_v1" # Deprecated 2015-04-21
      post "update_order_v2"
      post "pay_order_v2"
    end
    member do
      get "details" , :action => "details"
      get "details_v1", :action => "details_v1"
    end
  end
  match 'reset_redeem_password' => 'restaurants#resetredeem'
  match 'resetcode' => 'restaurants#resetpassword'
  # match 'communications' =>'notification#communications'
  resources :notification do
    collection do
      get "sendemail"
      post "sendemail"
      get "deletenotification"
      post "deletenotification"
      get "hidenotification"
      post "hidenotification"
      get "getnotifications"
      post "getnotifications"
      get "groupmessage"
      post "addgroup"
      get "sendmessage"
      post "add"
      get "search"
      post "search"
      get "sharepoints"
      post "sharepoints"
      # get "checkin"
      # post "checkin"
      get "mycommunications"
      get "communications"
      post "communications"

      post "sendweeklyprogress"
      get "cronweeklyreport"
      post "searchmycommunications"
      get "searchmycommunications"
      get "hide_reward_notification"
      post "hide_reward_notification"

      get "contact_group_message"
      get "contact_all_message"
      get "search_contact_message"
      get "send_customer_contact_message"

    end
  end

  resources :points do
    collection do
      get "action_status_prize"
      post "action_delete_prize_level"
      get "delete_prize_level"
      post "prize_level"
      post "insert"
      post "insert_prize"
      post "update_prize_level"
      get "prize"
      get "status_prize"
      post "socical_point"
      get "socical"
      get "userpoints",:action=>"resturantpoints"
      post "userpoints", :action => "resturantpoints"
      get "adduser"
      get "pointdetails"
      post 'pointdetails'
      get 'search'
      post 'search'
      get "pointaccept"
      post "pointaccept"
      get "sharesocialmedia"
      post "sharesocialmedia"
      get "redeemption"
      post "redeemption"
      get "ratingchange"
      post "ratingchange"
      get 'myrewards'
      post 'myrewards'
      get 'rewards'
      post 'rewards'
      get 'mypoint'
      get 'my_global_point'
      get 'point_detail'
      post "point_share_friend"
      post "reply_message"
      post "search_rewards"
      get "search_rewards"
      post "search_myrewards"
      get "search_myrewards"
      post "hide_reward_point"
      get "hide_reward_point"
      post "hide_my_reward_point"
      get "hide_my_reward_point"
      post "hide_reward_search"
      get  "hide_reward_search"
      get  "hide_my_reward_search"
      post "hide_my_reward_search"
      get "show_all_reward"
      get "show_all_my_reward"
      get "reward_export_csv"
      post "reward_export_csv"

      get "reward_export_pdf"
      post "reward_export_pdf"
      get "reward_export_xls"
      post "reward_export_xls"

      get "my_reward_export_csv"
      post "my_reward_export_csv"
      get "my_reward_export_pdf"
      post "my_reward_export_pdf"
      get "my_reward_export_xls"
      post "my_reward_export_xls"

      get "search_reward_export_csv"
      post "search_reward_export_csv"
      get "search_reward_export_pdf"
      post "search_reward_export_pdf"
      get "search_reward_export_xls"
      post "search_reward_export_xls"

      get "search_my_reward_export_csv"
      post "search_my_reward_export_csv"
      get "search_my_reward_export_pdf"
      post "search_my_reward_export_pdf"
      get "search_my_reward_export_xls"
      post "search_my_reward_export_xls"
      get 'get_item_and_categories'
    end
  end

  # PushNotificationPreferences
  match '/push_notification_preferences', via: 'get', to: 'push_notification_preferences#index'
  match '/push_notification_preferences', via: 'post', to: 'push_notification_preferences#create'

  resources :users do
    collection do
      get "login",:action=>"login"
      post "login", :action => "login"
      get "logout",:action=>"logout"
      post "logout", :action => "logout"
      post "settings",:action=> "update_settings"
      put "settings",:action=> "update_settings"
      post "register"
      post 'avatar'
      post 'set_avatar'
      get "points"
      post "register_social"
      post "check_token"
      post "forgot", :action=> "forgot_password"
      get "user_points" ,:action => "user_point"
      post "addsearchprofile"
      post "deletesearchprofile"
      post "editsearchprofile"
      get "searchprofile"
      get "searchfriend"
      get "getsearchprofile"
      post "set_default"
      post "feedback", :action => "mymenu_feedback"
      post "feedback_v1", :action => "mymenu_feedback_v1"
      get "register_level_up"
      get "test_register"
      get "recent_searches"
      put "checkin"
      get "checkin"
      post "register_v1"
      delete 'batch_delete'
    end
  end

  match "locations/search" => "locations#search"
  match "locations/advance" => "locations#advance_search"
  match "locations/normal_search" => "locations#normal_search"
  match "locations/normal_search_v1" => "locations#normal_search_v1"
  match "locations/run_default" => "locations#run_default_search"
  resources :locations , :only => [:index, :show] do
    collection do
      get 'menutype', :action => "menu_type"
      get 'itemtype', :action => "item_type"
      post 'share_via_social'
      post "search_restaurant_item"
      get "special_message_search"
      post "search_restaurant_item_v1"
    end
    member do
      get 'menu'
      get 'menu_v1'
      get 'comments', :action=>"comments"
      post 'comment', :action=>"add_comment"
      post 'favourite', :action => "add_favourite"
      post "update_comment"
      post 'update_braintree_customer_id'
    end
  end

  resources :items, :only => [:index, :show] do
    collection do
      post "share_item"
      get "item_detail"
      get "item_detail_v1"
    end
    member do
      get 'comments', :action=>"comments"
      post 'comment', :action=>"add_comment"
      post 'nexttime',:action=>"add_nexttime"
      post "update_comment"
      post "add_favourite"
    end
  end


  match 'admin' => 'admin#index',:as=>"admin"
  namespace :admin do
    resources :fundraisers do

      member do
        post 'gettype'
        post 'addtype'
      end
    end

    resources :users, only: [] do
      resource :suspend_account, only: [:update]
    end
    resources :packages, only: [:index, :show, :update] do
      member do
        post 'status'
      end
    end
    resources :locations do
      member do
        get 'images'
      end
      resources :items
    end
    resources :categories
    resources :pages
    resources :settings
    resources :profiles
    resources :app_services
    resources :plans
    resources :contests do
      collection do
        post "change_status"
      end
    end
    resources :prices do
      collection do
        get "user_assign_package"
        post "assign_package"
      end
    end
  end

namespace :menus_management do
  resources :statuses, only: [:update]
  resources :copy_shared, only: [:create] do
    collection do
      post 'status'
    end
  end
end

resources :menus do
  collection do
    get "mymenus"
    post "mymenus"
    get "menudetails"
    post "build_menu"
    get "switch_device"
    get "update_build_menu_items"
    get "build_preview"
    get "change_item_preview"
    get "display_combo_on_build_menu"
    get "preview"
    get "approve_menu"
    get "add_publish_date"
    post "menu_calendar_date"
    get "check_main_dish"
    delete 'batch_delete'
  end

  member do
    get "copy"
    get "display_main_dish"
    get "display_main_dish_extend"
    get "display_categories"
    get "display_categories_extend"
    get "check_items_quantity"
  end
end
  #manager routes
  resources :restaurants do
    collection do
      get 'index'
      post 'create'
      post "upload_logo"
      put "upload_logo"
      post "upload_image"
      put "upload_image"
      post "rotate_logo"
      post "rotate_image"
      get "delete_hour_operation"
      post "update_latLng"
      get "crop_logoURL"
    end
    member do
      get 'delete_logo'
      get 'manage_photos'
      put 'create_photos'
      get 'delete_photo'
      get 'profile_menu_csv'
      post 'add_fundraiser'
      post 'delete_fundraiser'
    end
    resources :notification do
      collection do
        get "communications"
        post "communications"
        post "searchcommunication"
        get "searchcommunication"
        get "searchmycommunications"

        # get "checksubmit"
      end
      member do
        get "usercommunications"
        get "usercommunicationsrating"
        # get "usercommunicationsratingreceipt"
        # get "ratingreceipt"
        # post "action_ratingreceipt"
        # get 'pullpoints'
        # post 'pull_user_points'
      end
    end
    resources :points  do
      collection do
        get 'rewards'
        get 'myrewards'
      end
    end

    resources :order  do
      collection do
        get 'restaurant_orders'
      end
    end

    resources :menus do
      collection do
        post "rotate_server"
        post "rotate_item_key"
        post "rotate_item"
        post "add_combo_item"
        post "add_category"
        get "edit_category"
        delete "delete_item"
        post "add_item"
        get "edit_item"
        post "add_item_key"
        post "add_item_option"
        post "edit_item_option"
        post "upload_image"
        put "upload_image"
        post "upload_server_avatar"
        put "upload_server_avatar"
        post "upload_item_key_image"
        put "upload_item_key_image"
        post "add_server"
        get "cancel_server"
        get "cancel_combo_item"
        get "cancel_profile"
        get "cancel_category"
        get "cancel_itemkey"
        get "cancel_item_option"
        get "cancel_item"
      end
      member do
        put "publish"
        put "unpublish"
        delete "remove_menu_from_build_menu"
        delete "remove_category_from_build_menu"
        delete "remove_item_from_build_menu"
      end
    end
    member do
      get "step3"
    end
    collection do
      post "resetpassword"
      get "mydashboard"
    end
    member do
      get "dashboard"
      get "calendar"
    end

    resources :contact  do
       collection do
         get 'search'
         post 'search'
         post 'create_group'
         get 'add_customer'
         get 'add_group_user'
         get 'delete_group'
         get 'favourite_items'
         get 'suspend_customer'
         get 'un_suspend_customer'
         get 'action_un_suspend_customer'
         get 'action_suspend_customer'
         get 'delete_customer'
         # get 'myrewards'
       end
    end

    # Rewards 3.0
    resources :rewards do
      member do
        post 'print_qr_code'
      end
    end
  end

  resources :tutorial_videos, :only=>[:edit, :update]
  resources :menu_items,:only=>[:edit,:destroy,:update] do
    collection do
      delete 'batch_delete'
    end
  end
  resources :item_key,:only=>[:edit,:destroy,:update] do
    collection do
      delete 'batch_delete'
    end
  end
  resources :item_option,:only=>[:edit,:destroy,:update] do
    collection do
      delete 'batch_delete'
    end
  end

  resources :servers,:only=>[:edit,:destroy,:update] do
    collection do
      delete 'batch_delete'
    end
  end

  #cancel button
  # resources :servers do
  #     collection do
  #     post "update"
  #     get "edit"
  #     delete "destroy"
  #     get  "cancel_update"
  #   end
  # end
  resources :category do
    collection do
      get "category"
      get "categories"
      get "category_items"
      get "category_items_v1"
      delete 'batch_delete'
    end
  end

  resources :contact  do
     collection do
       get 'search'
       post 'search'
       post 'create_group'
       get 'add_customer'
       get 'add_group_user'
       get 'delete_group'
       get 'suspend_customer'
       get 'delete_my_contact'
       # get 'myrewards'
     end
  end

  resources :combo_items, only: [:edit, :destroy, :update]

  resources :instruction do
    collection do
      get "get_instruction_categories"
      get "get_instruction_items"
      get "add_instruction_category_demo"
      get "delete_instruction_category_demo"
    end
  end
  resources :prize do
    collection do
      post 'send_to_friend'
      #get  'redeem_prize'
      post  'redeem_prize'
      get 'share_social'
      post 'send_to_email'
      post "register"
      get 'total_prize'
      get 'check_username'
      get 'check_email'
    end
  end

  get '/findpics', to: 'webservice#find_restaurant_pics'
  post '/showpics', to: 'webservice#show_restaurant_pics'

  # resources :devices, only: [:create]

  root :to => 'home#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id))(.:format)'
  match 'about'=>"home#about", :as=>"about"
  match 'contact_us'=>"home#contact_us", :as=>"contact_us"
  match 'contact'=>"home#contact", :as=>"contact"
  match 'update_contac'=>"home#update_contac", :as=>"update_contac"
  match 'oauth2authorize'=>"home#oauth2authorize", :as=>"oauth2authorize"
  match 'oauth2callback'=>"home#oauth2callback", :as=>"oauth2callback"
  match 'products'=>"home#products", :as=>"products"
  match 'checkout'=>"home#checkout", :as=>"checkout"
  match 'faqs'=>"home#faqs", :as=>"faqs"

  resources :location_images, :only => [:destroy]
  resource :payment_tokens, only: [:show], defaults: { format: 'json' }
  resources :payments, only: [:create, :destroy]
  resources :location_merchants, only: [:create, :new]

  post '/auth/cognos/callback', to: 'webservice#callback'
  post "/send_weekly_prize_report", to: 'notification#send_weekly_prize_report'
end
