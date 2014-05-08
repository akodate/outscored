require 'active_support/all'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'

# SET DATA DIRECTORY AND CREATE IF NONEXISTENT
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# SET DOMAIN URL AND TARGET URL
BASE_URL = "http://www.testprepreview.com/"

# HEADERS FOR REQUESTS
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# REGEXES
# WIKI_URL_REGEX = /\/wiki\// # FILTERS OUT UNWANTED LINKS
REGEX = /.*/

main_link = Nokogiri::HTML(open(BASE_URL)) # OPENS TARGET PAGE
test_links = main_link.css('body > table > tr > td:nth-child(1) > div > ul:nth-child(1) > li > a') # CSS SELECTOR FOR STREET LISTS



test_links.take(2).each_with_index do |a, test_count|

  test_name = a.text
  test_link = a.attributes['href'].value

  test_dir = "#{DATA_DIR}/" + test_name
  Dir.mkdir(test_dir) unless File.exists?(test_dir)
  test_fname = "#{test_dir}/#{File.basename(test_name)}.html"

  begin
    test_html = Nokogiri::HTML(open(test_link)) # OPENS TARGET PAGE
  # RESCUE EXCEPTION
  rescue => e
    puts "Error: #{e}"
    sleep 5
  # WRITE TO FILE
  else
    File.open(test_fname, 'w'){|file| file.write(test_html)}
    puts "\t...Success, saved TEST #{test_count}: '#{test_name}' to (#{test_fname})"
  # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
  ensure
    sleep 1.0 + rand
  end

  section_links = test_html.css('body > table > tr > td:nth-child(2) > table > tbody > tr:nth-child(2) > td:nth-child(1) > ul > li:nth-child(1) > a')

end