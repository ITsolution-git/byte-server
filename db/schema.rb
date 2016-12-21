# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20161221223802) do

  create_table "app_services", :force => true do |t|
    t.string   "name"
    t.integer  "limit"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "build_menus", :force => true do |t|
    t.integer  "item_id"
    t.integer  "menu_id"
    t.integer  "category_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "active"
    t.integer  "category_sequence", :default => 1
    t.integer  "item_sequence",     :default => 1
  end

  add_index "build_menus", ["item_id"], :name => "index_build_menus_on_item_id"
  add_index "build_menus", ["menu_id"], :name => "menu_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.integer  "category_points"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "description"
    t.string   "order"
    t.integer  "redemption_value"
    t.integer  "sequence"
  end

  create_table "checkins", :force => true do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "award_points", :default => true
  end

  add_index "checkins", ["location_id"], :name => "index_checkins_on_location_id"
  add_index "checkins", ["user_id"], :name => "index_checkins_on_user_id"

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "state_code"
    t.string   "country_code"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "zip"
    t.decimal  "lat",          :precision => 15, :scale => 6
    t.decimal  "lng",          :precision => 15, :scale => 6
  end

  add_index "cities", ["name"], :name => "ft_index_city_name"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "combo_item_categories", :force => true do |t|
    t.integer  "combo_item_id"
    t.integer  "category_id"
    t.integer  "quantity"
    t.integer  "sequence"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "combo_item_items", :force => true do |t|
    t.integer  "combo_item_id"
    t.integer  "item_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "combo_items", :force => true do |t|
    t.string   "name"
    t.integer  "menu_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "combo_type"
  end

  create_table "contact_groups", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "copy_shared_menu_statuses", :force => true do |t|
    t.integer  "location_id"
    t.string   "job_id"
    t.string   "menu_name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "countries", :force => true do |t|
    t.string   "country_code"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "cuisine_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customers_locations", :force => true do |t|
    t.integer  "location_id"
    t.integer  "user_id"
    t.integer  "is_deleted",  :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "status"
  end

  create_table "dates", :primary_key => "date_id", :force => true do |t|
    t.date    "date",                                                      :null => false
    t.string  "date_long",            :limit => 55,                        :null => false
    t.integer "timestamp",            :limit => 8,                         :null => false
    t.string  "weekend",              :limit => 10, :default => "Weekday", :null => false
    t.string  "day_of_week",          :limit => 10,                        :null => false
    t.string  "month",                :limit => 10,                        :null => false
    t.string  "month_short",          :limit => 3,                         :null => false
    t.integer "month_num",                                                 :null => false
    t.integer "month_day",                                                 :null => false
    t.integer "year",                                                      :null => false
    t.string  "year_string",          :limit => 4,                         :null => false
    t.string  "week_starting_monday", :limit => 2,                         :null => false
  end

  add_index "dates", ["date"], :name => "date", :unique => true
  add_index "dates", ["year", "week_starting_monday"], :name => "year_week"

  create_table "devices", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "parse_installation_id"
  end

  add_index "devices", ["parse_installation_id"], :name => "index_devices_on_parse_installation_id", :unique => true
  add_index "devices", ["user_id"], :name => "index_devices_on_user_id"

  create_table "dinner_types", :force => true do |t|
    t.integer  "location_id"
    t.string   "types"
    t.float    "point"
    t.integer  "key"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "rating",     :precision => 2, :scale => 1
    t.text     "comment"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "subject"
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "friendships", :force => true do |t|
    t.integer  "friendable_id"
    t.integer  "friend_id"
    t.string   "token"
    t.integer  "pending"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "fundraiser_types", :force => true do |t|
    t.integer  "fundraiser_id"
    t.string   "name"
    t.string   "image"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "fundraisers", :force => true do |t|
    t.string   "fundraiser_name"
    t.string   "name"
    t.string   "url"
    t.integer  "status"
    t.string   "phone"
    t.string   "email"
    t.string   "alt_email"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "credit_card_type"
    t.string   "credit_card_number"
    t.string   "credit_card_expiration_date"
    t.string   "credit_card_security_code"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "logo"
  end

  create_table "fundraisers_locations", :force => true do |t|
    t.integer "fundraiser_id"
    t.integer "location_id"
  end

  create_table "group_users", :force => true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "location_id"
  end

  create_table "hour_operations", :force => true do |t|
    t.integer  "day"
    t.string   "time_open"
    t.string   "time_close"
    t.integer  "location_id"
    t.integer  "group_hour"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "info_avatars", :force => true do |t|
    t.integer  "info_id"
    t.string   "image"
    t.string   "info_token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "infos", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "instruction_categories", :force => true do |t|
    t.string   "name"
    t.string   "icon"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
  end

  create_table "instruction_items", :force => true do |t|
    t.integer  "instruction_category_id"
    t.string   "item_name"
    t.string   "youtube_id"
    t.string   "times"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "item_comments", :force => true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.float    "rating"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "build_menu_id"
    t.integer  "hide_status",             :default => 0
    t.integer  "order_item_id"
    t.integer  "is_hide_reward_by_admin", :default => 0
    t.integer  "checkin_id"
  end

  add_index "item_comments", ["build_menu_id"], :name => "index_item_comments_on_build_menu_id"

  create_table "item_favourites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "favourite"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "build_menu_id"
  end

  add_index "item_favourites", ["build_menu_id"], :name => "build_menu_id"
  add_index "item_favourites", ["favourite"], :name => "favourite"
  add_index "item_favourites", ["user_id"], :name => "user_id"

  create_table "item_images", :force => true do |t|
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "image"
    t.string   "item_token"
  end

  create_table "item_item_keys", :force => true do |t|
    t.integer  "item_id"
    t.integer  "item_key_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "item_item_options", :force => true do |t|
    t.integer  "item_id"
    t.integer  "item_option_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "item_key_images", :force => true do |t|
    t.integer  "item_key_id"
    t.string   "image"
    t.string   "item_key_token"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "item_keys", :force => true do |t|
    t.string   "description"
    t.string   "name"
    t.integer  "location_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "token"
    t.integer  "image_id"
    t.boolean  "is_global"
  end

  add_index "item_keys", ["is_global"], :name => "index_item_keys_on_is_global"
  add_index "item_keys", ["name", "description"], :name => "ft_index_item_key"

  create_table "item_nexttimes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "nexttime"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "build_menu_id"
  end

  create_table "item_option_addons", :force => true do |t|
    t.string   "name"
    t.decimal  "price",          :precision => 5, :scale => 2, :default => 0.0
    t.integer  "item_option_id"
    t.datetime "created_at",                                                    :null => false
    t.datetime "updated_at",                                                    :null => false
    t.integer  "is_selected",                                  :default => 0
    t.integer  "is_deleted",                                   :default => 0
  end

  create_table "item_options", :force => true do |t|
    t.string   "name"
    t.integer  "only_select_one", :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "is_deleted",      :default => 0
    t.integer  "location_id",                    :null => false
  end

  create_table "item_photos", :force => true do |t|
    t.integer  "item_id"
    t.integer  "photo_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "item_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "item_types", ["name"], :name => "ft_index_item_type"

  create_table "items", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.decimal  "price",            :precision => 5, :scale => 2
    t.text     "description"
    t.decimal  "rating",           :precision => 3, :scale => 1
    t.text     "special_message"
    t.text     "ingredients"
    t.datetime "created_at",                                                        :null => false
    t.datetime "updated_at",                                                        :null => false
    t.integer  "item_type_id"
    t.integer  "calories"
    t.integer  "redemption_value"
    t.string   "token"
    t.boolean  "is_main_dish",                                   :default => false
  end

  add_index "items", ["location_id"], :name => "location_id"
  add_index "items", ["name", "description", "ingredients"], :name => "ft_index_item"

  create_table "location_comments", :force => true do |t|
    t.integer  "location_id"
    t.integer  "user_id"
    t.text     "text"
    t.integer  "rating"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "checkin_id"
  end

  create_table "location_contact_groups", :force => true do |t|
    t.integer  "location_owner_id"
    t.integer  "contact_group_id"
    t.string   "gg_contact_group_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "location_dates", :force => true do |t|
    t.string   "time_from"
    t.string   "time_to"
    t.string   "day"
    t.integer  "location_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "location_favourites", :force => true do |t|
    t.integer  "location_id"
    t.integer  "user_id"
    t.integer  "favourite"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "location_favourites", ["favourite"], :name => "favourite"
  add_index "location_favourites", ["location_id"], :name => "location_id"
  add_index "location_favourites", ["user_id"], :name => "user_id"

  create_table "location_image_photos", :force => true do |t|
    t.integer  "location_id"
    t.integer  "photo_id"
    t.integer  "index"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "location_images", :force => true do |t|
    t.string   "image"
    t.integer  "location_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "location_token"
    t.integer  "index"
  end

  create_table "location_logos", :force => true do |t|
    t.integer  "location_id"
    t.string   "image"
    t.string   "location_token"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "location_type", :force => true do |t|
    t.string   "Location Type"
    t.datetime "Created_At",    :null => false
    t.datetime "Updated_At",    :null => false
  end

  create_table "location_visiteds", :force => true do |t|
    t.integer  "location_id"
    t.integer  "user_id"
    t.integer  "visited",     :default => 0
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.decimal  "lat",                                  :precision => 15, :scale => 6
    t.decimal  "long",                                 :precision => 15, :scale => 6
    t.decimal  "rating",                               :precision => 3,  :scale => 1
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "slug"
    t.string   "zip"
    t.string   "phone"
    t.string   "url"
    t.integer  "owner_id"
    t.float    "tax",                                                                 :default => 0.0
    t.string   "bio",                 :limit => 10000
    t.integer  "global"
    t.string   "time_from"
    t.string   "time_to"
    t.datetime "created_at",                                                                               :null => false
    t.datetime "updated_at",                                                                               :null => false
    t.string   "chain_name"
    t.string   "token"
    t.string   "timezone"
    t.string   "rsr_admin"
    t.string   "rsr_manager"
    t.integer  "created_by"
    t.integer  "last_updated_by"
    t.integer  "info_id"
    t.boolean  "active",                                                              :default => true
    t.string   "twiter_url"
    t.string   "facebook_url"
    t.string   "google_url"
    t.string   "instagram_username"
    t.string   "linked_url"
    t.string   "primary_cuisine"
    t.string   "secondary_cuisine"
    t.string   "com_url"
    t.integer  "yelp_id"
    t.text     "description"
    t.string   "levelup_location_id"
    t.text     "customer_id"
    t.integer  "logo_id"
    t.integer  "copied_menus_cnt",                                                    :default => 0
    t.string   "logo_url"
    t.string   "service_fee_type",    :limit => 45,                                   :default => "fixed"
    t.float    "fee",                                                                 :default => 0.0
  end

  add_index "locations", ["chain_name"], :name => "chain_name"
  add_index "locations", ["lat"], :name => "index_locations_on_lat"
  add_index "locations", ["logo_id"], :name => "logo_id"
  add_index "locations", ["long"], :name => "index_locations_on_long"
  add_index "locations", ["name", "city", "state", "country"], :name => "ft_index_location"
  add_index "locations", ["name"], :name => "index_locations_on_name"
  add_index "locations", ["primary_cuisine"], :name => "index_locations_on_primary_cuisine"
  add_index "locations", ["secondary_cuisine"], :name => "index_locations_on_secondary_cuisine"
  add_index "locations", ["slug"], :name => "index_locations_on_slug"

  create_table "menu_servers", :force => true do |t|
    t.integer  "menu_id"
    t.integer  "server_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "menu_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "menus", :force => true do |t|
    t.integer  "location_id"
    t.string   "name"
    t.integer  "rating_grade"
    t.integer  "publish_status"
    t.datetime "publish_start_date"
    t.integer  "menu_type_id"
    t.string   "repeat_on"
    t.string   "publish_email"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "repeat_time"
    t.string   "repeat_time_to"
    t.datetime "published_date"
    t.boolean  "is_shared"
  end

  create_table "notifications", :force => true do |t|
    t.integer  "from_user"
    t.string   "to_user"
    t.string   "message",                 :limit => 10000
    t.string   "msg_type"
    t.integer  "location_id"
    t.string   "alert_logo"
    t.string   "alert_type"
    t.integer  "item_id"
    t.float    "points",                                   :default => 0.0
    t.integer  "status",                                   :default => 0
    t.string   "msg_subject"
    t.integer  "reply",                                    :default => 0
    t.integer  "received",                                 :default => 0
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "menu_rating",                              :default => 0
    t.text     "product_comment"
    t.integer  "hide_status",                              :default => 0
    t.text     "group_emails"
    t.integer  "item_comment_id"
    t.integer  "is_show",                                  :default => 1
    t.integer  "is_show_detail",                           :default => 1
    t.integer  "is_openms",                                :default => 0
    t.boolean  "is_delete_to_user",                        :default => false
    t.boolean  "is_delete_from_user",                      :default => false
    t.integer  "is_delete_by_admin",                       :default => 0
    t.integer  "is_hide_reward_by_admin",                  :default => 0
    t.string   "point_prize"
    t.integer  "location_comment_id"
  end

  add_index "notifications", ["alert_type"], :name => "alert_type"
  add_index "notifications", ["location_id"], :name => "location_id"

  create_table "numbers", :id => false, :force => true do |t|
    t.integer "number", :limit => 8
  end

  create_table "numbers_small", :id => false, :force => true do |t|
    t.integer "number"
  end

  create_table "order_item_combos", :force => true do |t|
    t.integer  "order_item_id"
    t.integer  "item_id"
    t.integer  "build_menu_id"
    t.string   "note"
    t.float    "use_point",        :default => 0.0
    t.float    "price"
    t.integer  "status",           :default => 0
    t.integer  "redemption_value"
    t.integer  "quantity"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "max_quantity",     :default => 0
    t.integer  "paid_quantity",    :default => -1
  end

  create_table "order_item_options", :force => true do |t|
    t.integer  "order_item_id"
    t.integer  "item_option_addon_id"
    t.decimal  "price",                  :precision => 5, :scale => 2, :default => 0.0
    t.integer  "quantity"
    t.integer  "status",                                               :default => 0
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.string   "item_option_addon_name",                                                :null => false
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "quantity"
    t.string   "note"
    t.float    "use_point",        :default => 0.0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "build_menu_id"
    t.integer  "status",           :default => 0
    t.integer  "item_id"
    t.float    "price",            :default => 0.0
    t.integer  "redemption_value", :default => 0
    t.integer  "combo_item_id"
    t.integer  "prize_id"
    t.integer  "share_prize_id"
    t.integer  "is_prize_item",    :default => 0
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.float    "total_tip"
    t.integer  "is_paid",                      :default => 0
    t.integer  "location_id"
    t.float    "tax"
    t.integer  "receipt_no"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "server_id"
    t.datetime "paid_date"
    t.integer  "is_cancel",                    :default => 0
    t.integer  "status",                       :default => 0
    t.float    "total_tax",                    :default => 0.0
    t.float    "total_price",                  :default => 0.0
    t.float    "sub_price",                    :default => 0.0
    t.integer  "read",                         :default => 0
    t.string   "timezone"
    t.string   "qrcode_levelup"
    t.float    "tip_percent"
    t.string   "payment_type"
    t.boolean  "pos",                          :default => false
    t.integer  "receipt_day_id",               :default => 1
    t.datetime "pickup_time"
    t.string   "phone",          :limit => 45
    t.integer  "ticket"
    t.string   "order_id"
    t.boolean  "is_refunded",                  :default => false
    t.string   "orderscol",      :limit => 45
    t.float    "fee",                          :default => 0.0
  end

  create_table "packages", :force => true do |t|
    t.string   "package_id"
    t.boolean  "enabled"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "photos", :force => true do |t|
    t.string   "photoable_id"
    t.string   "photoable_type"
    t.string   "crop_x"
    t.string   "crop_y"
    t.string   "crop_w"
    t.string   "crop_h"
    t.string   "angle"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "rate",           :default => 1
    t.string   "name"
  end

  add_index "photos", ["photoable_type", "photoable_id"], :name => "index_photos_on_photoable_type_and_photoable_id"

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "prices", :force => true do |t|
    t.integer  "plan_id"
    t.integer  "app_service_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "prize_redeems", :force => true do |t|
    t.integer  "prize_id"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "from_user"
    t.integer  "is_redeem"
    t.integer  "level"
    t.integer  "redeem_value"
    t.string   "timezone"
    t.integer  "share_prize_id"
    t.string   "from_redeem"
  end

  create_table "prizes", :force => true do |t|
    t.string   "name"
    t.integer  "redeem_value"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "level"
    t.string   "role"
    t.integer  "is_delete",       :default => 0
    t.integer  "status_prize_id"
    t.integer  "build_menu_id"
    t.integer  "category_id"
  end

  create_table "profiles", :force => true do |t|
    t.string   "restaurant_name"
    t.string   "mailing_address"
    t.string   "mailing_city"
    t.string   "mailing_country"
    t.string   "mailing_zip"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "physical_address"
    t.string   "physical_city"
    t.string   "physical_country"
    t.string   "physical_zip"
    t.string   "physical_state"
    t.string   "mailing_state"
  end

  create_table "push_notification_preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "notification_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "push_notification_preferences", ["user_id"], :name => "index_push_notification_preferences_on_user_id"

  create_table "push_notification_subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "push_notifiable_type"
    t.integer  "push_notifiable_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "push_notification_subscriptions", ["user_id", "push_notifiable_type", "push_notifiable_id"], :name => "unique_user_resource_combo", :unique => true

  create_table "push_notifications", :force => true do |t|
    t.integer  "push_notifiable_id"
    t.string   "push_notifiable_type"
    t.text     "message"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.text     "additional_data"
    t.string   "notification_type"
  end

  create_table "redactor_assets", :force => true do |t|
    t.integer  "user_id"
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "redactor_assets", ["assetable_type", "assetable_id"], :name => "idx_redactor_assetable"
  add_index "redactor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_redactor_assetable_type"

  create_table "rewards", :force => true do |t|
    t.string   "name"
    t.string   "photo"
    t.string   "share_link"
    t.datetime "available_from"
    t.datetime "expired_until"
    t.string   "timezone"
    t.text     "description"
    t.integer  "quantity"
    t.integer  "stats"
    t.integer  "location_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "redeem_by_qrcode", :default => false
  end

  add_index "rewards", ["location_id"], :name => "index_rewards_on_location_id"

  create_table "search_profiles", :force => true do |t|
    t.string   "name"
    t.string   "location_rating"
    t.string   "item_price"
    t.string   "item_reward"
    t.string   "item_rating"
    t.string   "radius"
    t.string   "item_type"
    t.string   "menu_type"
    t.string   "text"
    t.string   "server_rating"
    t.integer  "isdefault",       :default => 0
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "server_avatars", :force => true do |t|
    t.integer  "server_id"
    t.string   "image"
    t.string   "server_token"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "server_favourites", :force => true do |t|
    t.integer  "server_id"
    t.integer  "user_id"
    t.integer  "favourite",  :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "server_ratings", :force => true do |t|
    t.integer  "server_id"
    t.integer  "user_id"
    t.integer  "rating"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "text"
  end

  create_table "servers", :force => true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.decimal  "rating",      :precision => 2, :scale => 1
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.text     "bio"
    t.string   "token"
    t.integer  "avatar_id"
  end

  create_table "services", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "uname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "share_points", :force => true do |t|
    t.integer  "friendships_id"
    t.integer  "location_id"
    t.float    "points"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "share_prizes", :force => true do |t|
    t.integer  "prize_id"
    t.integer  "from_user"
    t.integer  "to_user"
    t.string   "token"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "status",      :default => 0
    t.integer  "is_redeem",   :default => 0
    t.string   "from_share"
    t.integer  "is_refunded", :default => 0
    t.integer  "share_id",    :default => 0
    t.integer  "is_limited",  :default => 0
    t.integer  "location_id"
  end

  create_table "social_points", :force => true do |t|
    t.integer  "facebook_point",    :default => 0
    t.integer  "google_plus_point", :default => 0
    t.integer  "twitter_point",     :default => 0
    t.integer  "instragram_point",  :default => 0
    t.integer  "ibecon_point",      :default => 0
    t.integer  "location_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "comment_point",     :default => 0
  end

  create_table "social_shares", :force => true do |t|
    t.integer  "location_id"
    t.integer  "user_id"
    t.string   "socai_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "date_time"
    t.integer  "item_id"
  end

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "state_code"
    t.string   "country_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "status_prizes", :force => true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "subscription_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "plan_id"
    t.integer  "location_id"
    t.string   "plan_name"
    t.datetime "next_billing_date"
    t.boolean  "billing_active"
  end

  add_index "subscriptions", ["billing_active", "next_billing_date"], :name => "index_subscriptions_on_billing_active_and_next_billing_date"
  add_index "subscriptions", ["next_billing_date"], :name => "index_subscriptions_on_next_billing_date"

  create_table "taggings", :force => true do |t|
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tag_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tutorial_videos", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_avatars", :force => true do |t|
    t.integer  "user_id"
    t.string   "image"
    t.string   "user_token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "location_owner_id"
    t.string   "gg_contact_id"
    t.string   "etag"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "user_location_contact_groups", :force => true do |t|
    t.integer  "user_contact_id"
    t.integer  "location_contact_group_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "user_points", :force => true do |t|
    t.integer  "user_id"
    t.string   "point_type"
    t.integer  "location_id"
    t.float    "points"
    t.integer  "status"
    t.integer  "is_give"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_prizes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "prize_id"
    t.integer  "location_id"
    t.integer  "is_sent_notification"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "user_profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name",           :limit => 50
    t.string   "image"
    t.string   "show_type",      :limit => 20
    t.string   "publish_date",   :limit => 30
    t.string   "unpublish_date", :limit => 30
    t.string   "zipcode",        :limit => 10
    t.string   "radius",         :limit => 10
    t.text     "tags"
    t.string   "latitude",       :limit => 50
    t.string   "longitude",      :limit => 50
    t.integer  "order_num"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_recent_searches", :force => true do |t|
    t.integer  "user_id"
    t.string   "keyword",     :limit => 1000
    t.string   "search_type", :limit => 11
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "user_rewards", :force => true do |t|
    t.boolean  "is_reedemed", :default => false
    t.integer  "reward_id"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "location_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "user_rewards", ["location_id"], :name => "index_user_rewards_on_location_id"
  add_index "user_rewards", ["receiver_id"], :name => "index_user_rewards_on_receiver_id"
  add_index "user_rewards", ["reward_id"], :name => "index_user_rewards_on_reward_id"
  add_index "user_rewards", ["sender_id"], :name => "index_user_rewards_on_sender_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                  :default => ""
    t.string   "username"
    t.float    "points",                 :default => 0.0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "avatar"
    t.string   "role"
    t.string   "zip"
    t.string   "phone"
    t.integer  "app_service_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "customer_id"
    t.boolean  "active_braintree"
    t.string   "subscription_id"
    t.integer  "parent_user_id"
    t.string   "gg_access_token"
    t.string   "gg_refresh_token"
    t.datetime "time_request"
    t.integer  "is_register",            :default => 0
    t.string   "email_profile"
    t.string   "token"
    t.string   "access_token_levelup"
    t.integer  "account_number"
    t.integer  "is_add_friend",          :default => 0
    t.integer  "contact_delete",         :default => 0
    t.integer  "price_id"
    t.integer  "is_suspended",           :default => 0
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "employer_id"
    t.integer  "avatar_id"
    t.string   "braintree_token"
    t.boolean  "has_byte",               :default => false
    t.string   "social_image_url"
    t.string   "restaurant_type"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "zipcodes", :force => true do |t|
    t.string "zip"
    t.string "city"
    t.string "state"
  end

end
