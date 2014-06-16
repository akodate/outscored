require 'json'
require 'open-uri'
require 'pry'
require 'nokogiri'
require 'active_support/all'

require 'mechanize'
require 'logger'

# SET DATA DIRECTORY AND CREATE IF NONEXISTENT
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# SET DOMAIN URL AND TARGET URL
BASE_URL = "http://www.4tests.com"
TARGET_URL = "http://www.4tests.com/exams/exams.asp"

# HEADERS FOR REQUESTS
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

mech = Mechanize.new { |agent|
  agent.follow_meta_refresh = true
}
mech.log = Logger.new "mechanize.log"

class Mechanize::Page::Link
  def asp_link_args
    href = self.attributes['href']
    href =~ /\(([^()]+)\)/ && $1.split(/\W?\s*,\s*\W?/).map(&:strip).map {|i| i.gsub(/^['"]|['"]$/,'')}
  end

  def asp_click(action_arg = nil)
    etarget,earg = asp_link_args.values_at(0, 1)

    f = self.page.form_with(:name => 'frmQuestion')
    f.action = asp_link_args.values_at(action_arg) if action_arg
    f['dir'] = etarget
    f['nqid'] = earg
    binding.pry
    f.submit
  end
end

main_page = Nokogiri::HTML(open(TARGET_URL)) # OPENS TARGET PAGE
tests = main_page.css('#double > li > a')
puts tests

questions = []
choices = []
answers = []
explanations = []

tests.each do |test|

  # GETS INITIAL TEST PAGE
  remote_url = BASE_URL + test['href']
  puts "Fetching TEST PAGE at #{remote_url}"
  begin
    mech.get remote_url
  rescue Exception=>e
    puts "Error: #{e}"
    sleep 5
  else
    puts '*' * 50
    puts mech.page.uri
    mech.page.forms[1].submit
    puts '*' * 50
  ensure
    sleep 1.0 + rand
  end

  remote_url = 'http://www.4tests.com/exams/questions.asp?exid=23100918&googlebot=13'
  puts "Fetching QUESTION PAGE at #{remote_url}"

  mech.get(remote_url) do |question_page|
    puts question_page

    question_page.links.each do |link|
      puts link
    end

    question_page.forms.each do |form|
      puts form
    end

    puts mech
    puts mech.page
    link = question_page.link_with(:text => 'View Answer')
    puts link
    puts mech.page.uri
    binding.pry
    full_page = mech.page.link_with(:text => 'View Answer').asp_click()
    binding.pry
    puts full_page.body
    puts mech.page.uri

    # frmQuestion

    # full_page = mech.page.link_with(:text => 'View Answer').click
    # full_page = mech.click(question_page.link_with(:text => /View Answer/))
    # full_page = question_page.link_with(:text => /View Answer/).click()

    # full_page.links.each do |link|
    #   test = link.text.strip
    #   next unless text.length > 0
    #   puts text
    # end

    throw ''

  end


  # # GETS QUESTION
  # remote_url = mech.page.uri
  # puts "Fetching question at #{remote_url}"
  # begin
  #   question_page = open(remote_url, HEADERS_HASH).read
  # rescue Exception=>e
  #   puts "Error: #{e}"
  #   sleep 5
  # else
  #   puts '?' * 50
  #   puts question_page[0..500]
  #   puts '?' * 50
  # ensure
  #   sleep 1.0 + rand
  # end

  # remote_url = mech.page.uri
  # puts "Clicking show answers at #{remote_url}"
  # begin
  #   mech.get remote_url
  # rescue Exception=>e
  #   puts "Error: #{e}"
  #   sleep 5
  # else
  #   puts '?' * 50
  #   puts mech.page.uri
  #   binding.pry
  #   question_page = mech.click(page.link_with(:text => /View Answer/))
  #   puts mech.page.uri
  #   puts '?' * 50
  # ensure
  #   sleep 1.0 + rand
  # end

end



# # SET DATA DIRECTORY AND CREATE IF NONEXISTENT
# DATA_DIR = "lib/assets"
# Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# # SET DOMAIN URL AND TARGET URL
# BASE_WIKIPEDIA_URL = "http://en.wikipedia.org"
# TARGET_URL = "#{BASE_WIKIPEDIA_URL}/wiki/List_of_streets_and_roads_in_Hong_Kong"

# # HEADERS FOR REQUESTS
# HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# # REGEXES
# WIKI_URL_REGEX = /\/wiki\// # FILTERS OUT UNWANTED LINKS
# CHINESE_REGEX = /[[:^ascii:]]+(?=\)|<\/span>)/ # FINDS CHINESE STREET NAME ON PAGE

# # OTHER DECLARATIONS
# target_page = Nokogiri::HTML(open(TARGET_URL)) # OPENS TARGET PAGE
# local_fname = "#{DATA_DIR}/#{File.basename('Hong_Kong_Streets')}.json" # SETS DATA FILENAME
# lists = target_page.css('div#content div#bodyContent div#mw-content-text table.multicol tr td') # CSS SELECTOR FOR STREET LISTS
# chinese_roads = [] # CREATES ARRAY FOR STREETS

# class StreetData
#   include Mongoid::Document
#   include Mongoid::Timestamps

#   field :street_data, type: Array
# end


# desc "Runs scraper and saves results to file"
# task :run => :environment do

#   lists.each do |list|
#     puts list.css('h3').text
#     puts list.css('dl').text

#     count = -1
#     list.css('ul li a').each do |a|
#       count += 1
#       # ONLY LOOK AT EVERY 12TH RESULT (FOR DEMO PURPOSES)
#       if a['href'] =~ WIKI_URL_REGEX && count % 12 == 0
#         puts count

#         # GETS HREF FROM CSS-SELECTED LINK AND FETCHES PAGE
#         remote_url = BASE_WIKIPEDIA_URL + a['href']
#         puts "Fetching #{remote_url}"
#         # READ PAGE
#         begin
#           scrape_page = open(remote_url, HEADERS_HASH).read
#         # RESCUE EXCEPTION
#         rescue Exception=>e
#           puts "Error: #{e}"
#           sleep 5
#         else
#           # RETURN REGEX MATCH FROM PAGE
#           chinese_road = CHINESE_REGEX.match(scrape_page)
#           puts("'" + a.text + "' is '" + chinese_road.to_s + "'")
#           # PUSHES ENGLISH STREET LINK & CHINESE STREET KEY/VALUE PAIR
#           chinese_roads.push({ a.text => chinese_road.to_s }) if chinese_road
#         # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
#         ensure
#           sleep 1.0 + rand
#         end
#       end
#     end
#   end

#   # SAVE FILE
#   File.open(local_fname, 'w'){|file| file.write(chinese_roads.to_json)}
#   puts "\t...Success, saved to #{local_fname}"

# end

