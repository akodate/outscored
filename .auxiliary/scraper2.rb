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

#REGEXES
SECTION_REGEX = /(?<=Section:\s).*/
ANSWER_REGEX = /(?<=tr:nth-of-type\()./
EXPLANATION_REGEX = /(?<=<b>Explanation of Answer:<\/b><br>).*/

mech = Mechanize.new { |agent|
  agent.follow_meta_refresh = true
}
mech.log = Logger.new "mechanize.log"


# ******************************************************
# ******************************************************
# ******************************************************


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
    f.submit
  end
end

def get_answer(mech, test)
  remote_url = mech.page.uri
  puts "Fetching ANSWER PAGE at #{remote_url}..."
  begin
    full_page = mech.page.link_with(:text => 'View Answer').asp_click()
  rescue => e
    puts "Error: #{e}"
    sleep 5
  else
    puts ''
  ensure
    sleep 1.0 + rand
  end

  section = find_section(mech)
  unless test[section]
    test[section] = {}
  end

  test[section]['questions'] ||= []
  test[section]['choices'] ||= []
  test[section]['answers'] ||= []
  test[section]['explanations'] ||= []

  puts "*** QUESTION NUMBER " + (test[section]['questions'].count + 1).to_s + " ***"
  puts "Section: " + section
  puts "Question: " + (test[section]['questions'].push find_question(mech)).last.to_s
  puts "Choices: " + (test[section]['choices'].push find_choices(mech)).last.to_s
  puts "Answer: " + (test[section]['answers'].push find_answer(mech)).last.to_s
  puts "Explanation: " + (test[section]['explanations'].push find_explanation(mech)).last.to_s
  puts ""

  get_question(mech, test)
end

def find_section(mech)
  selector = '#frmQuestion > table > tr > td > table > tr:nth-child(1) > td > b'
  if mech.page.search(selector)
    return mech.page.search(selector).text.match(SECTION_REGEX).to_s
  end
end

def find_question(mech)
  selector = '.question'
  if mech.page.search(selector)
    return mech.page.search(selector)[1].to_html.gsub(/\r\s*\t/, "")
  end
end

def find_choices(mech)
  selector = '#frmQuestion > table > tr > td > table > tr:nth-child(3) > td > table > tr > td > font > img'
  if mech.page.search(selector)

    # Makes 'ABCD' style multiple choice array
    arr = []
    mech.page.search(selector).each_with_index do |choice, i|
      if arr == []
        arr.push('A')
      else
        arr.push arr[i - 1].next
      end
    end
    return arr

  end
end

def find_answer(mech)
  selector = '.answerred'
  if mech.page.search(selector)
    # Gets number of right choice from nth child
    num = mech.page.search(selector)[0].css_path.scan(ANSWER_REGEX)[1].to_i - 2

    num -= 1
    let = 'A'
    num.times do
      let.next!
    end
    return let

  end
end

def find_explanation(mech)
  selector = '#frmQuestion > table > tr > td > table > tr:nth-child(4) > td > table > tr:nth-child(1) > td'
  if mech.page.search(selector)
    return mech.page.search(selector).to_html.match(EXPLANATION_REGEX).to_s
  end
end

def get_question(mech, test)
  remote_url = mech.page.uri
  puts "Fetching QUESTION PAGE at #{remote_url}..."
  begin
    full_page = mech.page.link_with(:text => 'Next Question').asp_click()
  rescue => e
    puts "Error: #{e}"
    sleep 5
  else
    puts ''
  ensure
    sleep 1.0 + rand
  end

  if mech.page.link_with(:text => 'View Answer')
    get_answer(mech, test)
  else
    return test
  end

end

def save_test(test, test_dir)
  test.each do |section|
    section_dir = "#{test_dir}/#{section.first}"
    Dir.mkdir(section_dir) unless File.exists?(section_dir)
    puts "\t...Saved SECTION as #{section_dir}"
    save_json(section, section_dir)
  end
end

def save_json(section, section_dir)
  arr = []
  section[1]['questions'].each_with_index do |question, i|
    arr[i] = {}
    arr[i]['question'] = section[1]['questions'][i]
    arr[i]['choices'] = section[1]['choices'][i]
    arr[i]['answer'] = section[1]['answers'][i]
    arr[i]['explanation'] = section[1]['explanations'][i]
  end
  json_file = "#{section_dir}/#{section.first}.json"
  File.open(json_file, 'w'){|file| file.write(arr.to_json)}
  puts "\t...Saved QUESTIONS as #{json_file}"
end


# ******************************************************
# ******************************************************
# ******************************************************


main_page = Nokogiri::HTML(open(TARGET_URL)) # OPENS TARGET PAGE
tests = main_page.css('#double > li > a')
puts tests

test_set = {}

tests.each_with_index do |test|

  # GET INITIAL TEST PAGE
  remote_url = BASE_URL + test['href']
  puts "Fetching TEST PAGE at #{remote_url}..."
  begin
    mech.get remote_url
  rescue Exception=>e
    puts "Error: #{e}"
    sleep 5
  else
    puts '*' * 50
    test_name = mech.page.search('.examtitle').text.gsub(/\*/, '')
    test_set[test_name] = {}
    puts ">>>>> Test name is: " + test_name
    mech.page.forms[1].submit
  ensure
    sleep 1.0 + rand
  end

  test_dir = "#{DATA_DIR}/#{test_name}"
  next if File.exists?(test_dir)
  Dir.mkdir(test_dir)

  test_set[test_name] = get_answer(mech, test_set[test_name])
  save_test(test_set[test_name], test_dir)

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

