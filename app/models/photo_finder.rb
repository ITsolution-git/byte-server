require 'open-uri'

class PhotoFinder
  def self.get_twitter_pics(searchString)
    pic_urls = []

    $twitter_client.search("filter:links " + searchString, {result_type: "popular", count: 50}).take(50).each do |tweet|
      if tweet.media? && tweet.media[0].class == Twitter::Media::Photo
        pic_urls << tweet.media[0].media_url
      end
    end

    return pic_urls
  end

  def self.get_instagram_pics(searchString)
    # This method needs further refactoring (functional but ugly)
    temp_urls = []
    pic_urls = []

    url = "http://websta.me/tag/" + searchString.gsub(/\s+/, "") + "?lang=en"

    doc = Nokogiri::HTML(open(url))

    doc.css(".photobox").each do |photobox|
      temp_urls << photobox.css("a")[0]["href"]
    end

    temp_urls.each do |t_url|
      if pic_urls.size < 50
        doc = Nokogiri::HTML(open("http://websta.me" + t_url))
        pic_urls << doc.css(".mainimg_wrapper img")[0]["src"]
      end
    end

    return pic_urls
  end
end