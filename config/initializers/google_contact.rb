# RATE_GROUP = "Rate"
# FAVORITE_GROUP = "Set Favorite"
# SHARE_MENU_ITEMS_GROUP = "Share Menu Items"
# SHARE_RESTAURANT_POINTS_GROUP = "Share Restaurant Points"
# ORDER_GROUP = "Order"
# PAY_GROUP = "Pay"
# ACCEPT_POINTS_GROUP = "Accept Points"

# RESTAURANT_GROUP = "Restaurant"
# DINER_GROUP = "Diner"

# require "net/https"
# require "nokogiri"
# require "nori"
# require "cgi"

# GContacts::Client.class_eval do
#     API_URI = {
#       :contacts => {:all => "https://www.google.com/m8/feeds/contacts/default/%s", :create => URI("https://www.google.com/m8/feeds/contacts/default/full"), :get => "https://www.google.com/m8/feeds/contacts/default/%s/%s", :update => "https://www.google.com/m8/feeds/contacts/default/full/%s", :batch => URI("https://www.google.com/m8/feeds/contacts/default/full/batch")},
#       :groups => {:all => "https://www.google.com/m8/feeds/groups/default/%s", :create => URI("https://www.google.com/m8/feeds/groups/default/full"), :get => "https://www.google.com/m8/feeds/groups/default/%s/%s", :update => "https://www.google.com/m8/feeds/groups/default/full/%s", :batch => URI("https://www.google.com/m8/feeds/groups/default/full/batch")}
#     }

#     ##
#     # Immediately updates the element on Google
#     # @param [GContacts::Element] Element to update
#     #
#     # @raise [Net::HTTPError]
#     # @raise [GContacts::InvalidResponse]
#     # @raise [GContacts::InvalidRequest]
#     # @raise [GContacts::InvalidKind]
#     #
#     # @return [GContacts::Element] Updated element returned from Google
#     def update!(element)
#       uri = API_URI["#{element.category}s".to_sym]
#       raise InvalidKind, "Unsupported kind #{element.category}" unless uri

#       xml = "<?xml version='1.0' encoding='UTF-8'?>\n#{element.to_xml}"

#       data = Nori.parse(http_request(:put, URI(uri[:get] % [:full, File.basename(element.id)]), :body => xml, :headers => {"Content-Type" => "application/atom+xml", "If-Match" => element.etag}), :nokogiri)
#       unless data["entry"]
#         raise InvalidResponse, "Updated but response wasn't a valid element"
#       end

#       GContacts::Element.new(data["entry"])
#     end
# end


# GContacts::Element.class_eval do

#   attr_accessor :title, :content, :data, :category, :etag, :group_ids, :modifier_flag, :id
#   attr_reader :edit_uri, :updated, :batch
#   ##
#   # Creates a new element by parsing the returned entry from Google
#   # @param [Hash, Optional] entry Hash representation of the XML returned from Google
#   #
#   def initialize(entry=nil)
#     @data = {}
#     return unless entry

#     @id, @updated, @content, @title, @etag = entry["id"], entry["updated"], entry["content"], entry["title"], entry["@gd:etag"]
#     if entry["category"]
#       @category = entry["category"]["@term"].split("#", 2).last
#       @category_tag = entry["category"]["@label"] if entry["category"]["@label"]
#     end

#     # Parse out all the relevant data
#     entry.each do |key, unparsed|
#       if key =~ /^gd:/
#         if unparsed.is_a?(Array)
#           @data[key] = unparsed.map {|v| parse_element(v)}
#         else
#           @data[key] = [parse_element(unparsed)]
#         end
#       elsif key =~ /^batch:(.+)/
#         @batch ||= {}

#         if $1 == "interrupted"
#           @batch["status"] = "interrupted"
#           @batch["code"] = "400"
#           @batch["reason"] = unparsed["@reason"]
#           @batch["status"] = {"parsed" => unparsed["@parsed"].to_i, "success" => unparsed["@success"].to_i, "error" => unparsed["@error"].to_i, "unprocessed" => unparsed["@unprocessed"].to_i}
#         elsif $1 == "id"
#           @batch["status"] = unparsed
#         elsif $1 == "status"
#           if unparsed.is_a?(Hash)
#             @batch["code"] = unparsed["@code"]
#             @batch["reason"] = unparsed["@reason"]
#           else
#             @batch["code"] = unparsed.attributes["code"]
#             @batch["reason"] = unparsed.attributes["reason"]
#           end

#         elsif $1 == "operation"
#           @batch["operation"] = unparsed["@type"]
#         end
#       end
#     end
#     @group_ids = []
#     if entry["gContact:groupMembershipInfo"].kind_of?(Array)
#       entry["gContact:groupMembershipInfo"].each do |group|
#         @group_ids << group["@href"]
#       end
#       # @modifier_flag = :delete if entry["gContact:groupMembershipInfo"]["@deleted"] == "true"
#       # @group_id = entry["gContact:groupMembershipInfo"]["@href"]
#     else

#     end

#     # Need to know where to send the update request
#     if entry["link"].is_a?(Array)
#       entry["link"].each do |link|
#         if link["@rel"] == "edit"
#           @edit_uri = URI(link["@href"])
#           break
#         end
#       end
#     end
#   end

#   ##
#   # Converts the entry into XML to be sent to Google
#   def to_xml(batch=false)
#     if batch
#       xml = " <entry"
#     else
#       xml = "<atom:entry xmlns:atom='http://www.w3.org/2005/Atom' xmlns:gContact='http://schemas.google.com/contact/2008' xmlns:gd='http://schemas.google.com/g/2005'"
#     end
#     xml << " gd:etag='#{@etag}'" if @etag
#     xml << ">\n"

#     if batch
#       xml << "  <batch:id>#{@modifier_flag}</batch:id>\n"
#       xml << "  <batch:operation type='#{@modifier_flag == :create ? "insert" : @modifier_flag}'/>\n"
#     end

#     # While /base/ is whats returned, /full/ is what it seems to actually want
#     if @id
#       xml << "  <id>#{@id.to_s}</id>\n"
#     end

#     unless @modifier_flag == :delete
#       if batch
#         xml << "  <category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/g/2008##{@category}'/>\n"
#         xml << "  <title>#{@title}</title>\n"
#       else
#         xml << "  <atom:category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/g/2008##{@category}'/>\n"
#         xml << "  <atom:title>#{@title}</atom:title>\n"
#       end
#       xml << "  <updated>#{Time.now.utc.iso8601.to_s}</updated>\n"
#       if @content
#         xml << "  <atom:content type='text'>#{@content}</atom:content>\n"
#       end

#       @group_ids.each do |group_id|
#         xml << "  <gContact:groupMembershipInfo deleted='false' href='#{group_id}'/>\n" if group_id
#       end
#       @data.each do |key, parsed|
#         xml << handle_data(key, parsed, 2)
#       end
#     end

#     if batch
#       xml << "</entry>\n"
#     else
#       xml << "</atom:entry>\n"
#     end
#   end
# end