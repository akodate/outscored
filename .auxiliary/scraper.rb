require 'json'
require 'open-uri'
require 'pry'
require 'nokogiri'
require 'active_support/all'

# SET DATA DIRECTORY AND CREATE IF NONEXISTENT
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# SET DOMAIN URL AND TARGET URL
BASE_URL = "http://www.testprepreview.com/"

# HEADERS FOR REQUESTS
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# REGEXES
CONTENT_REGEX = /((?<=addthis)(?:.*?)(?=enoch|<iframe))/im
SELF_ASSESSMENT_LINKS_REGEX = /(?<=self.assessment).*/im
ANSWER_SECTION_REGEX = /<h\d>.{,35}?(?:Answer).*?<\/h\d>.+/im

QUESTION_REGEX = /((?:<p.{1,20}?)(?:<em>)?(?:<strong>)?.?.?\d{1,3}\.\s+.*?(?:\/p>))/m
CHOICE_REGEX_OL = /((?:(?:<ol.{1,15}?)(?:<li>.*?<\/li>.{1,15}?))*.?<\/ol>)/m
CHOICE_REGEX_P = /((?:<p>\s?\s?[a]\.).*?(?:[b-z]\.)*?<\/p>)/im
ANSWER_REGEX = //
EXPLANATION_REGEX = /(<p>(?:<strong>)?(?:<em>)?\d{1,3}\.?:?\s?\s?.*?<\/p>)/im

class Question
  def initialize (question, choices, answer, explanation)
    @question = question
    @choices = choices
    @answer = answer
    @explanation = explanation
  end

  attr_accessor :question, :choices, :answer, :explanation
end

visited_urls = []
main_link = Nokogiri::HTML(open(BASE_URL)) # OPENS TARGET PAGE
test_links = main_link.css('body > table > tr > td:nth-child(1) > div > ul:nth-child(1) > li > a') # CSS SELECTOR FOR STREET LISTS

def detect_test(page_html)
  if p_array = page_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) > p')
    return detect_questions(p_array, page_html)
  else
    return nil
  end
end

def detect_questions(p_array, page_html)
  json_array = []
  question_array = []
  choices_array = []
  explanation_array = []
  p_array.each_with_index do | p, p_count |
    if QUESTION_REGEX.match(p.to_s) && !(ANSWER_SECTION_REGEX.match(page_html.to_s).to_s.include?(p.to_s))
      question = QUESTION_REGEX.match(p.to_s)
      question_array.push(question[0])
      puts(p_count.to_s + " QUESTION: " + question[0])
    end
    if choices = CHOICE_REGEX_P.match(p.to_s)
      choices_array.push(choices[0])
      puts(p_count.to_s + " P CHOICES: " + choices[0])
    elsif p.next_element.name == 'ol' && p.next_element.children.length > 2
      choices = CHOICE_REGEX_OL.match(p.next_element.to_s)
      choices_array.push(choices[0])
      puts(p_count.to_s + " OL CHOICES: " + choices[0])
    end
    if EXPLANATION_REGEX.match(p.to_s) && (ANSWER_SECTION_REGEX.match(page_html.to_s).to_s.include?(p.to_s))
      explanation = EXPLANATION_REGEX.match(p.to_s)
      explanation_array.push(explanation[0])
      puts(p_count.to_s + " EXPLANATION: " + explanation[0])
    end
  end
  question_array.length.times do | index |
    binding.pry
    json_array[index] = Question.new( question_array[index], choices_array[index], explanation_array[index], explanation_array[index] )
  end
  return json_array
end



test_links.take(12).each_with_index do |a, test_count|

  next if test_count < 10

  test_name = a.text
  test_link = a.attributes['href'].value

  test_dir = "#{DATA_DIR}/" + test_name
  Dir.mkdir(test_dir) unless File.exists?(test_dir)
  test_fname = "#{test_dir}/#{File.basename(test_name)}.html"
  test_json = "#{test_dir}/#{File.basename(test_name)}.json"

  begin
    test_html = Nokogiri::HTML(open(test_link)) # OPENS TARGET PAGE
  # RESCUE EXCEPTION
  rescue => e
    puts "Error: #{e}"
    sleep 5
  # WRITE TO FILE
  else
    File.open(test_fname, 'w'){|file| file.write(test_html)}
    puts " ...Success, saved TEST #{test_count}: '#{test_name}' to (#{test_fname})"
  # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
  ensure
    sleep 1.0 + rand
  end

  json_array = detect_test(test_html)
  if json_array
    File.open(test_json, 'w'){|file| file.write(json_array.to_json)}
    puts "\t...Success, saved NEW TEST JSON to #{test_json}"
  end
  visited_urls.push(test_link)

  return

  # DETECT IF TEST IS ON PAGE
    # SAVE TO JSON IF IT IS ('test_name Practice Questions.json')
  # DETECT IF SELF ASSESSMENT LINKS OR OTHER LINKS ARE ON THE PAGE
  # START AT BODY, STOP AT IFRAME/BYLINE
    # IF THEY ARE SAME SITE, CHECK IF YOU'VE BEEN TO THAT SECTION BEFORE
      # IF NOT
        # OPEN PAGE
        # ADD URL TO VISITED LINKS ARRAY ALONG WITH HTML
        # DETECT IF TEST IS ON THE PAGE
          # SAVE TO HTML, SAVE TO JSON, ADD JSON TO URL ENTRY
      # IF SO
        # IF URL ENTRY HAS JSON, SAVE PAGE FROM VISITED LINKS ARRAY

  section_links.take(2).each_with_index do |aa, section_count|

    section_name = aa.text
    section_link = BASE_URL + aa.attributes['href'].value

    test_dir = "#{DATA_DIR}/" + test_name + "/" + section_name
    Dir.mkdir(test_dir) unless File.exists?(test_dir)
    section_fname = "#{test_dir}/#{File.basename(section_name)}.html"
    section_json = "#{test_dir}/#{File.basename(section_name)}.json"

    begin
      section_html = Nokogiri::HTML(open(section_link)) # OPENS TARGET PAGE
    # RESCUE EXCEPTION
    rescue => e
      puts "Error: #{e}"
      sleep 5
    # WRITE TO FILE
    else
      File.open(section_fname, 'w'){|file| file.write(section_html)}
      puts "     -Saved SECTION #{section_count}: '#{section_name}' to (...#{section_fname[-20, 20]})"
    # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
    ensure
      sleep 1.0 + rand
    end

    questions = section_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) > p > strong')

    question_array = [] # CREATES ARRAY FOR QUESTIONS

    binding.pry

    questions.each_with_index do |p, question_count|

      puts "Item: #{question_count}"
      puts p

    end

  end

end


    # lists.each do |list|
    #   puts list.css('h3').text
    #   puts list.css('dl').text

    #   count = -1
    #   list.css('ul li a').each do |a|
    #     count += 1
    #     # ONLY LOOK AT EVERY 12TH RESULT (FOR DEMO PURPOSES)
    #     if a['href'] =~ WIKI_URL_REGEX && count % 12 == 0
    #       puts count

    #       # GETS HREF FROM CSS-SELECTED LINK AND FETCHES PAGE
    #       remote_url = BASE_WIKIPEDIA_URL + a['href']
    #       puts "Fetching #{remote_url}"
    #       # READ PAGE
    #       begin
    #         scrape_page = open(remote_url, HEADERS_HASH).read
    #       # RESCUE EXCEPTION
    #       rescue => e
    #         puts "Error: #{e}"
    #         sleep 5
    #       # RETURN REGEX MATCH FROM PAGE
    #       else
    #         chinese_road = CHINESE_REGEX.match(scrape_page)
    #         puts("'" + a.text + "' is '" + chinese_road.to_s + "'")
    #         # PUSHES ENGLISH STREET LINK & CHINESE STREET KEY/VALUE PAIR
    #         chinese_roads.push({ a.text => chinese_road.to_s }) if chinese_road
    #       # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
    #       ensure
    #         sleep 1.0 + rand
    #       end
    #     end
    #   end
    # end

    # # SAVE FILE
    # File.open(local_fname, 'w'){|file| file.write(chinese_roads.to_json)}
    # puts "\t...Success, saved to #{local_fname}"


    # File.open(section_fname, 'w'){|file| file.write(section_html)}
    # File.open(section_fname, 'w'){|file| file.write(section_json.to_json)}
    # puts "\t...Success, saved NEW TEST PAGE to #{html_fname}"


  # class StreetData
  #   include Mongoid::Document
  #   include Mongoid::Timestamps

  #   field :street_data, type: Array
  # end


    # data = StreetData.new(street_data: JSON.parse(File.open('lib/assets/Hong_Kong_Streets.json', 'r').read))
    # if data.save
    #   puts "\t...Success, saved to database"
    # end

