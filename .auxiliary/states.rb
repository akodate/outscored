require 'json'
require 'open-uri'
require 'pry'
require 'nokogiri'
require 'active_support/all'

# SET DATA DIRECTORY AND CREATE IF NONEXISTENT
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# SET DOMAIN URL AND TARGET URL
BASE_URL = "http://en.wikipedia.org/wiki/List_of_state_achievement_tests_in_the_United_States"

# HEADERS FOR REQUESTS
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

page = Nokogiri::HTML(open(BASE_URL)) # OPENS TARGET PAGE
lists = page.css('#mw-content-text > table > tr')
puts lists

states = []
names = []
long_names = []

lists.each do |tr|
  if tr.css('td:nth-child(1)')[0] && tr.css('td:nth-child(3)') && tr.css('td:nth-child(4)')

    states.push(tr.css('td:nth-child(1)')[0].text)
    names.push(tr.css('td:nth-child(3)')[0].text)
    long_names.push(tr.css('td:nth-child(4)')[0].text)
  end
end

puts states
puts names
puts long_names

# File.open('states.txt', 'w'){|file| file.write(states + names + long_names)}
# puts "\t...Success"

