require 'nokogiri'
require 'open-uri'
require 'json'

# SET DATA DIRECTORY AND CREATE IF NONEXISTENT
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# SET DOMAIN URL AND TARGET URL
BASE_WIKIPEDIA_URL = "http://en.wikipedia.org"
TARGET_URL = "#{BASE_WIKIPEDIA_URL}/wiki/List_of_streets_and_roads_in_Hong_Kong"

# HEADERS FOR REQUESTS
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# REGEXES
WIKI_URL_REGEX = /\/wiki\// # FILTERS OUT UNWANTED LINKS
CHINESE_REGEX = /[[:^ascii:]]+(?=\)|<\/span>)/ # FINDS CHINESE STREET NAME ON PAGE

# OTHER DECLARATIONS
target_page = Nokogiri::HTML(open(TARGET_URL)) # OPENS TARGET PAGE
local_fname = "#{DATA_DIR}/#{File.basename('Hong_Kong_Streets')}.json" # SETS DATA FILENAME
lists = target_page.css('div#content div#bodyContent div#mw-content-text table.multicol tr td') # CSS SELECTOR FOR STREET LISTS
chinese_roads = [] # CREATES ARRAY FOR STREETS

# class StreetData
#   include Mongoid::Document
#   include Mongoid::Timestamps

#   field :street_data, type: Array
# end

lists.each do |list|
  puts list.css('h3').text
  puts list.css('dl').text

  count = -1
  list.css('ul li a').each do |a|
    count += 1
    # ONLY LOOK AT EVERY 12TH RESULT (FOR DEMO PURPOSES)
    if a['href'] =~ WIKI_URL_REGEX && count % 12 == 0
      puts count

      # GETS HREF FROM CSS-SELECTED LINK AND FETCHES PAGE
      remote_url = BASE_WIKIPEDIA_URL + a['href']
      puts "Fetching #{remote_url}"
      # READ PAGE
      begin
        scrape_page = open(remote_url, HEADERS_HASH).read
      # RESCUE EXCEPTION
      rescue Exception=>e
        puts "Error: #{e}"
        sleep 5
      else
        # RETURN REGEX MATCH FROM PAGE
        chinese_road = CHINESE_REGEX.match(scrape_page)
        puts("'" + a.text + "' is '" + chinese_road.to_s + "'")
        # PUSHES ENGLISH STREET LINK & CHINESE STREET KEY/VALUE PAIR
        chinese_roads.push({ a.text => chinese_road.to_s }) if chinese_road
      # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
      ensure
        sleep 1.0 + rand
      end
    end
  end
end

# SAVE FILE
File.open(local_fname, 'w'){|file| file.write(chinese_roads.to_json)}
puts "\t...Success, saved to #{local_fname}"



    # data = StreetData.new(street_data: JSON.parse(File.open('lib/assets/Hong_Kong_Streets.json', 'r').read))
    # if data.save
    #   puts "\t...Success, saved to database"
    # end

