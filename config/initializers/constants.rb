# User roles
USER_ROLE = 'user'
CASHIER_ROLE = 'cashier'
ADMIN_ROLE = 'admin'
OWNER_ROLE = 'owner'
RTR_ADMIN_ROLE = 'restaurant_admin'
RTR_MANAGER_ROLE = 'restaurant_manager'
SUSPENDED_STATUS = 'Suspended'
ACTIVE_STATUS = 'Active'
ROLE_RESTAURANT_NAME = {
  OWNER_ROLE => 'admin',
  RTR_ADMIN_ROLE => 'admin_tmp',
  RTR_MANAGER_ROLE => 'manager'
}

# Actions and message types
SHARING_POINTS = "Sharing Points"
FRIEND_REQUEST = "Friend Requests"
DIRECT_MESSAGE = 'Direct Message'
GENERAL_MESSAGE = 'General Message'
RATING_MESSAGE = 'Rating Message'
RESTAURANT_RATING_MESSAGE = 'Restaurant Rating Message'
POINTS_MESSAGE = 'Points Message'
REDEMPTION     =  'Redemption'
POINTS_REFUNDED = 'Points Refunded'
PRIZES_SHARED = 'Prizes Shared'
PRIZES_REFUNDED = "Prizes Refunded"
DIRECT_ALERT_TYPE = 'DirectMarketing'
GENERAL_ALERT_TYPE = 'GeneralMarketing'
#DIRECT_ALERT_TYPE = 'Direct Message'
#GENERAL_ALERT_TYPE = 'General Message'
RATING_ALERT_TYPE = 'Rating Reward'
RESTAURANT_RATING_ALERT_TYPE = 'Restaurant Rating Reward'
RATING_TYPE = 'Rating'
POINTS_ALERT_TYPE = 'Points Message'
ORDER_ALERT_TYPE = 'Order'
PRIZE_ALERT_TYPE = 'Prize Message'

# Push notifications
PUSH_NOTIFIABLE_TYPES = %w(Item Location User) # These are resource types that correspond to Parse "channels"
PUSH_NOTIFICATION_TYPES = [ # These are the types of notifications that can be sent through a Parse "channel"
  # NOTE: If you want to enable a new push notification type,
  # don't forget to run the following command in the console:
  # User.all.each {|u| u.update_push_notification_settings!}

  # 'geo_item_on_special', # Geo-Based Specials Notification (TBD)
  # 'fav_item_price_change', # Favorited item price drop (TBD)
  # 'fav_item_on_special', # Favorited item added to special (TBD per 2015-04-09 Slack chat)
  # 'rated_high_on_special', # New special at restaurant rated A or above by user (TBD)
  'prize_received', # Prize received by user (implemented)
  'msg_from_restaurant', # Message to user from restaurant (implemented)
  'item_rating_low', # User rating item D or below (implemented)
  'friend_request', # Friend requests (implemented)
  'points_received', # Points received by user (implemented)
  'order_submitted',
  'order_completed'
]

# Points values
DEFAULT_POINTS_AWARDED_FOR_CHECKIN = 0
DEFAULT_POINTS_AWARDED_FOR_COMMENT = 0

# Checkin defaults
MAX_COMMENTS_PER_LOCATION_CHECKIN = 5
CHECKINS_VALID_FOR_HOURS = 6

EMPTY_DAY= 'Choose A Day'
JOIN_MULTIPLE_DAY= ', ...'

PMI = 'PMI'
GMI = 'GMI'
PMI_GMI = 'PMI,GMI'
GMI_PMI = 'GMI,PMI'

PENDING_STATUS = 0
APPROVE_STATUS = 1
PUBLISH_STATUS = 2

ACTIVE = true # TODO: Refactor all occurrences of 'ACTIVE' in the codebase, because it's silly to obfuscate the use of a boolean.

POINT_FROM_CHECKIN = "Points from Checkin"
POINT_FROM_GRADE = "Points from Grading"
POINT_FROM_RESTAURANT = "Points from Restaurant"
RECEIVED_POINT_TYPE = "Points Received"

BASIC = 'basic'
DELUXE = 'deluxe'
PREMIUM = 'premium'

RATING_LOGO = '/assets/rating-alert.png'
POINT_LOGO = '/assets/reward-alert.png'
GENERAL_MESSAGE_LOGO = '/assets/general-message.png'

MY_FAVOURITES = '/assets/myfavor.png'
MY_POINTS = '/assets/mypoint.png'
MY_ORDERS = '/assets/myorders.png'
MY_WALLETS = '/assets/mywallet.png'

SIGNUP_SUCCESS_SUBJECT = 'Simpler dining begins now, welcome to BYTE!'
SIGNUP_SUCCESS_BODY    = 'Congratulations on creating your very own BYTE Account! You can now search and select your favorite restaurants and food items! The more you rate, the better BYTE can serve you!'
SHAREPOINT_SUBJECT ='Point Message'
PAY_ORDER_BODY = "Thank you for your order, you may now rate any of the items you tried for the next 2 hours from MyOrder, please let us know about your experience!"
PAY_ORDER_BODY_RATING_ALL="You've paid your order and got points for rating items. Please go to MyOrder to view your receipt."
WEEKDAY = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Sartuday']

MENU_STATUS = {
  PENDING_STATUS => 'Pending',
  APPROVE_STATUS => 'Approved',
  PUBLISH_STATUS => 'Active'
}

MESSAGE_TYPE = [
  [DIRECT_MESSAGE, DIRECT_ALERT_TYPE],
  [GENERAL_MESSAGE, GENERAL_ALERT_TYPE],
  [RATING_MESSAGE, RATING_ALERT_TYPE],
  [POINTS_MESSAGE, POINTS_ALERT_TYPE]
]

GROUP_DAY_EVERY = "9"
GROUP_DAY_WEEKENDS = "10"
GROUP_DAY_EVERY_REPLACE = ["2","3","4","5","6"]
GROUP_DAY_WEEKENDS_REPLACE = ["7","8"]

MONTH = ["01", "02", "03", "04",
         "05", "06", "07", "08",
         "09", "10", "11", "12"]

DAY  = ["Monday","Tuesday","Wednesday",
    "Thursday","Friday","Saturday","Sunday"]

TIMES = ["12:00 AM","12:30 AM","01:00 AM","01:30 AM","02:00 AM","02:30 AM","03:00 AM","03:30 AM","04:00 AM","04:30 AM","05:00 AM","05:30 AM","06:00 AM","06:30 AM","07:00 AM","07:30 AM","08:00 AM","08:30 AM","09:00 AM","09:30 AM","10:00 AM","10:30 AM","11:00 AM","11:30 AM","12:00 PM","12:30 PM","01:00 PM","01:30 PM","02:00 PM","02:30 PM","03:00 PM","03:30 PM","04:00 PM","04:30 PM","05:00 PM","05:30 PM","06:00 PM","06:30 PM","07:00 PM","07:30 PM","08:00 PM","08:30 PM","09:00 PM","09:30 PM","10:00 PM","10:30 PM","11:00 PM","11:30 PM"]

DEFAULT_TIMEZONE = 'America/Chicago'

CUISINE_TYPE  = [
  ["American","American"],
  ["Asian","Asian"],
  ["Bar Food","Bar Food"],
  ["BBQ","BBQ"],
  ["Cafe", "Cafe"],
  ["Cajun & Creole","Cajun & Creole"],
  ["Carribean", "Carribean"],
  ["Chinese","Chinese"],
  ["Coffee Shop", "Coffee Shop"],
  ["Cuban","Cuban"],
  ["English","English"],
  ["Ethiopian","Ethiopian"],
  ["Food Truck", "Food Truck"],
  ["French","French"],
  ["Fusion","Fusion"],
  ["German","German"],
  ["Greek","Greek"],
  ["Hawaiian","Hawaiian"],
  ["Hungarian","Hungarian"],
  ["Indian","Indian"],
  ["Irish","Irish"],
  ["Italian","Italian"],
  ["Japanese","Japanese"],
  ["Mediterranean","Mediterranean"],
  ["Mexican","Mexican"],
  ["Moroccan","Moroccan"],
  ["Portuguese","Portuguese"],
  ["Seafood","Seafood"],
  ["Southern/ Soul Food","Southern/ Soul Food"],
  ["Southwestern","Southwestern"],
  ["Spanish","Spanish"],
  ["Steakhouse","Steakhouse"],
  ["Swedish","Swedish"],
  ["Thai", "Thai"]
]

COUNTRIES = [['Afghanistan','Afghanistan'],
['Albania','Albania'],
['Algeria','Algeria'],
['American Samoa','American Samoa'],
['Andorra','Andorra'],
['Angola','Angola'],
['Anguilla','Anguilla'],
['Antarctica','Antarctica'],
['Antigua And Barbuda','Antigua And Barbuda'],
['Argentina','Argentina'],
['Armenia','Armenia'],
['Aruba','Aruba'],
['Australia','Australia'],
['Austria','Austria'],
['Azerbaijan','Azerbaijan'],
['Bahamas','Bahamas'],
['Bahrain','Bahrain'],
['Bangladesh','Bangladesh'],
['Barbados','Barbados'],
['Belarus','Belarus'],
['Belgium','Belgium'],
['Belize','Belize'],
['Benin','Benin'],
['Bermuda','Bermuda'],
['Bhutan','Bhutan'],
['Bolivia','Bolivia'],
['Bosnia And Herzegovina','Bosnia And Herzegovina'],
['Botswana','Botswana'],
['Bouvet Island','Bouvet Island'],
['Brazil','Brazil'],
['British Indian Ocean Territory','British Indian Ocean Territory'],
['Brunei Darussalam','Brunei Darussalam'],
['Bulgaria','Bulgaria'],
['Burkina Faso','Burkina Faso'],
['Burundi','Burundi'],
['Cambodia','Cambodia'],
['Cameroon','Cameroon'],
['Canada','Canada'],
['Cape Verde','Cape Verde'],
['Cayman Islands','Cayman Islands'],
['Central African Republic','Central African Republic'],
['Chad','Chad'],
['Chile','Chile'],
['China','China'],
['Christmas Island','Christmas Island'],
['Cocos (keeling) Islands','Cocos (keeling) Islands'],
['Colombia','Colombia'],
['Comoros','Comoros'],
['Congo','Congo'],
['Congo','Congo'],
['The Democratic Republic Of The','The Democratic Republic Of The'],
['Cook Islands','Cook Islands'],
['Costa Rica','Costa Rica'],
['Cote D\'ivoire','Cote D\'ivoire'],
['Croatia','Croatia'],
['Cuba','Cuba'],
['Cyprus','Cyprus'],
['Czech Republic','Czech Republic'],
['Denmark','Denmark'],
['Djibouti','Djibouti'],
['Dominica','Dominica'],
['Dominican Republic','Dominican Republic'],
['East Timor','East Timor'],
['Ecuador','Ecuador'],
['Egypt','Egypt'],
['El Salvador','El Salvador'],
['Equatorial Guinea','Equatorial Guinea'],
['Eritrea','Eritrea'],
['Estonia','Estonia'],
['Ethiopia','Ethiopia'],
['Falkland Islands (malvinas)','Falkland Islands (malvinas)'],
['Faroe Islands','Faroe Islands'],
['Fiji','Fiji'],
['Finland','Finland'],
['France','France'],
['French Guiana','French Guiana'],
['French Polynesia','French Polynesia'],
['French Southern Territories','French Southern Territories'],
['Gabon','Gabon'],
['Gambia','Gambia'],
['Georgia','Georgia'],
['Germany','Germany'],
['Ghana','Ghana'],
['Gibraltar','Gibraltar'],
['Greece','Greece'],
['Greenland','Greenland'],
['Grenada','Grenada'],
['Guadeloupe','Guadeloupe'],
['Guam','Guam'],
['Guatemala','Guatemala'],
['Guinea','Guinea'],
['Guinea-bissau','Guinea-bissau'],
['Guyana','Guyana'],
['Haiti','Haiti'],
['Heard Island And Mcdonald Islands','Heard Island And Mcdonald Islands'],
['Holy See (vatican City State)','Holy See (vatican City State)'],
['Honduras','Honduras'],
['Hong Kong','Hong Kong'],
['Hungary','Hungary'],
['Iceland','Iceland'],
['India','India'],
['Indonesia','Indonesia'],
['Iran','Iran'],
['Islamic Republic Of','Islamic Republic Of'],
['Iraq','Iraq'],
['Ireland','Ireland'],
['Israel','Israel'],
['Italy','Italy'],
['Jamaica','Jamaica'],
['Japan','Japan'],
['Jordan','Jordan'],
['Kazakstan','Kazakstan'],
['Kenya','Kenya'],
['Kiribati','Kiribati'],
['Korea','Korea'],
['Democratic People\'s Republic Of','Democratic People\'s Republic Of'],
['Korea','Korea'],
['Republic Of','Republic Of'],
['Kosovo','Kosovo'],
['Kuwait','Kuwait'],
['Kyrgyzstan','Kyrgyzstan'],
['Lao People\'s Democratic Republic','Lao People\'s Democratic Republic'],
['Latvia','Latvia'],
['Lebanon','Lebanon'],
['Lesotho','Lesotho'],
['Liberia','Liberia'],
['Libyan Arab Jamahiriya','Libyan Arab Jamahiriya'],
['Liechtenstein','Liechtenstein'],
['Lithuania','Lithuania'],
['Luxembourg','Luxembourg'],
['Macau','Macau'],
['Macedonia','Macedonia'],
['The Former Yugoslav Republic Of','The Former Yugoslav Republic Of'],
['Madagascar','Madagascar'],
['Malawi','Malawi'],
['Malaysia','Malaysia'],
['Maldives','Maldives'],
['Mali','Mali'],
['Malta','Malta'],
['Marshall Islands','Marshall Islands'],
['Martinique','Martinique'],
['Mauritania','Mauritania'],
['Mauritius','Mauritius'],
['Mayotte','Mayotte'],
['Mexico','Mexico'],
['Micronesia','Micronesia'],
['Federated States Of','Federated States Of'],
['Moldova','Moldova'],
['Republic Of','Republic Of'],
['Monaco','Monaco'],
['Mongolia','Mongolia'],
['Montserrat','Montserrat'],
['Montenegro','Montenegro'],
['Morocco','Morocco'],
['Mozambique','Mozambique'],
['Myanmar','Myanmar'],
['Namibia','Namibia'],
['Nauru','Nauru'],
['Nepal','Nepal'],
['Netherlands','Netherlands'],
['Netherlands Antilles','Netherlands Antilles'],
['New Caledonia','New Caledonia'],
['New Zealand','New Zealand'],
['Nicaragua','Nicaragua'],
['Niger','Niger'],
['Nigeria','Nigeria'],
['Niue','Niue'],
['Norfolk Island','Norfolk Island'],
['Northern Mariana Islands','Northern Mariana Islands'],
['Norway','Norway'],
['Oman','Oman'],
['Pakistan','Pakistan'],
['Palau','Palau'],
['Palestinian Territory','Palestinian Territory'],
['Occupied','Occupied'],
['Panama','Panama'],
['Papua New Guinea','Papua New Guinea'],
['Paraguay','Paraguay'],
['Peru','Peru'],
['Philippines','Philippines'],
['Pitcairn','Pitcairn'],
['Poland','Poland'],
['Portugal','Portugal'],
['Puerto Rico','Puerto Rico'],
['Qatar','Qatar'],
['Reunion','Reunion'],
['Romania','Romania'],
['Russian Federation','Russian Federation'],
['Rwanda','Rwanda'],
['Saint Helena','Saint Helena'],
['Saint Kitts And Nevis','Saint Kitts And Nevis'],
['Saint Lucia','Saint Lucia'],
['Saint Pierre And Miquelon','Saint Pierre And Miquelon'],
['Saint Vincent And The Grenadines','Saint Vincent And The Grenadines'],
['Samoa','Samoa'],
['San Marino','San Marino'],
['Sao Tome And Principe','Sao Tome And Principe'],
['Saudi Arabia','Saudi Arabia'],
['Senegal','Senegal'],
['Serbia','Serbia'],
['Seychelles','Seychelles'],
['Sierra Leone','Sierra Leone'],
['Singapore','Singapore'],
['Slovakia','Slovakia'],
['Slovenia','Slovenia'],
['Solomon Islands','Solomon Islands'],
['Somalia','Somalia'],
['South Africa','South Africa'],
['South Georgia And The South Sandwich Islands','South Georgia And The South Sandwich Islands'],
['Spain','Spain'],
['Sri Lanka','Sri Lanka'],
['Sudan','Sudan'],
['Suriname','Suriname'],
['Svalbard And Jan Mayen','Svalbard And Jan Mayen'],
['Swaziland','Swaziland'],
['Sweden','Sweden'],
['Switzerland','Switzerland'],
['Syrian Arab Republic','Syrian Arab Republic'],
['Taiwan','Taiwan'],
['Province Of China','Province Of China'],
['Tajikistan','Tajikistan'],
['Tanzania','Tanzania'],
['United Republic Of','United Republic Of'],
['Thailand','Thailand'],
['Togo','Togo'],
['Tokelau','Tokelau'],
['Tonga','Tonga'],
['Trinidad And Tobago','Trinidad And Tobago'],
['Tunisia','Tunisia'],
['Turkey','Turkey'],
['Turkmenistan','Turkmenistan'],
['Turks And Caicos Islands','Turks And Caicos Islands'],
['Tuvalu','Tuvalu'],
['Uganda','Uganda'],
['Ukraine','Ukraine'],
['United Arab Emirates','United Arab Emirates'],
['United Kingdom','United Kingdom'],
['United States','United States'],
['United States Minor Outlying Islands','United States Minor Outlying Islands'],
['Uruguay','Uruguay'],
['Uzbekistan','Uzbekistan'],
['Vanuatu','Vanuatu'],
['Venezuela','Venezuela'],
['Viet Nam','Viet Nam'],
['Virgin Islands','Virgin Islands'],
['British','British'],
['Virgin Islands','Virgin Islands'],
['U.s.','U.s.'],
['Wallis And Futuna','Wallis And Futuna'],
['Western Sahara','Western Sahara'],
['Yemen','Yemen'],
['Zambia','Zambia'],
['Zimbabwe','Zimbabwe']]

# define radius for search feature
DEFAULT_SEARCH_RADIUS_IN_MILES = 20
GG_PLACES_RADIUS = 32186 # unit is meter (<=> 20 miles)
GG_PLACES_API_KEY = 'AIzaSyAZlCja2sb4EECOC3ZHvzavoCol6uF43Mc'
# 'AIzaSyBLpqgYZR8xYEZKiCoPcbKJIOR9X0TklHc'  # Dev key
#'AIzaSyAQb8P1Zw4NYOTfVtFmN4VOEqRfp56fr4c' Customer's key
UPDATE_ORDER_ITEM = "update_order_item feature"
UPDATE_ORDER = "update_order feature"

BLUEMIX_APP_ID = '4bbf71af-67d1-47a3-b3ef-de81e0d6d156'


# FOR TESTING
DEFAULT_LATITUDE = '30.29128' # Austin, TX
DEFAULT_LONGITUDE = '-97.73858' # Austin, TX

BYTE_PLANS = { byte: 'byte',
               order_and_pay: 'order_pay',
               cognos: 'cognos'
             }
