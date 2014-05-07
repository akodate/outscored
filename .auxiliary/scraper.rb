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

counter = 0



test_links.each do |a|

  counter += 1
  puts(counter)
  if counter > 2
    return
  end

  test_name = a.text
  test_link = a.attributes['href'].value

  test_dir = "#{DATA_DIR}/" + test_name
  Dir.mkdir(test_dir) unless File.exists?(test_dir)
  html_fname = "#{test_dir}/#{File.basename(test_name)}.html"

  begin
    test_html = Nokogiri::HTML(open(test_link)) # OPENS TARGET PAGE
  # RESCUE EXCEPTION
  rescue => e
    puts "Error: #{e}"
    sleep 5
  # WRITE TO FILE
  else
    File.open(html_fname, 'w'){|file| file.write(test_html)}
    puts "\t...Success, saved NEW TEST PAGE to #{html_fname}"
  # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
  ensure
    sleep 1.0 + rand
  end

  section_links = test_html.css('body > table > tr > td:nth-child(2) > table > tbody > tr:nth-child(2) > td:nth-child(1) > ul > li:nth-child(1) > a')



  section_links.each do |aa|

    section_name = aa.text
    section_link = aa.attributes['href'].value

    test_dir = "#{DATA_DIR}/" + test_name + "/" + section_name
    Dir.mkdir(test_dir) unless File.exists?(test_dir)
    html_fname = "#{test_dir}/#{File.basename(section_name)}.html"
    json_fname = "#{test_dir}/#{File.basename(section_name)}.json"

    section_html = Nokogiri::HTML(open(section_link)) # OPENS TARGET PAGE

    questions = test_html.css('body > table > tbody > tr > td:nth-child(2) > table > tbody > tr:nth-child(2) > td:nth-child(1) > p')

    question_array = [] # CREATES ARRAY FOR QUESTIONS

    questions.each do









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
          rescue => e
            puts "Error: #{e}"
            sleep 5
          # RETURN REGEX MATCH FROM PAGE
          else
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


    File.open(html_fname, 'w'){|file| file.write(section_html)}
    File.open(html_fname, 'w'){|file| file.write(section_json.to_json)}
    puts "\t...Success, saved NEW TEST PAGE to #{html_fname}"


  # class StreetData
  #   include Mongoid::Document
  #   include Mongoid::Timestamps

  #   field :street_data, type: Array
  # end


    # data = StreetData.new(street_data: JSON.parse(File.open('lib/assets/Hong_Kong_Streets.json', 'r').read))
    # if data.save
    #   puts "\t...Success, saved to database"
    # end

