require 'json'
require 'open-uri'
require 'pry'
require 'nokogiri'
require 'active_support/all'

class Object
  def xx
    self.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  end
end

# SET DATA DIRECTORY AND CREATE IF NONEXISTENT
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

# SET DOMAIN URL AND TARGET URL
BASE_URL = "http://www.testprepreview.com/"

# HEADERS FOR REQUESTS
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# REGEXES
CONTENT_REGEX = /((?<=addthis)(?:.*)(?=enoch|<iframe))/im
SELF_ASSESSMENT_LINKS_REGEX = /(?<=self.assessment).*/im
ANSWER_SECTION_REGEX = /<h\d>.{,35}?(?:Answer).*?<\/h\d>.+/im
BASE_URL_REGEX = /((?<=a\shref=")(?:(?:http:\/\/www.testprepreview.com\/)|(?:[^(?:http:\/\/www.)])).*?(?="))/
EXTERNAL_URL_REGEX = /((?:http:\/\/www.))/

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

useful_urls = {}
visited_urls = []
main_link = Nokogiri::HTML(open(BASE_URL)) # OPENS TARGET PAGE
test_links = main_link.css('body > table > tr > td:nth-child(1) > div > ul:nth-child(1) > li > a')

def detect_test(page_html)
  p_array = page_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) > div.testq > ol > li')
  if p_array.length > 1
    return detect_questions(p_array, page_html, 'li')
  end

  p_array = page_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) > p')
  if p_array.length > 1
    return detect_questions(p_array, page_html, 'p')
  else
    return []
  end
end

def detect_questions(p_array, page_html, type)
  json_array = []
  question_array = []
  choices_array = []
  explanation_array = []
  visited = false
  p_array.each_with_index do | p, p_count |

    if QUESTION_REGEX.match(p.to_s.xx) && !(ANSWER_SECTION_REGEX.match(page_html.to_s.xx).to_s.xx.include?(p.to_s.xx))
      question = QUESTION_REGEX.match(p.to_s.xx)
      question_array.push(question[0])
      # puts(p_count.to_s.xx + " QUESTION: " + question[0])
    end

    if choices = CHOICE_REGEX_P.match(p.to_s.xx)
      choices_array.push(choices[0])
      # puts(p_count.to_s.xx + " P CHOICES: " + choices[0])
    elsif p.next_element && p.next_element.name == 'ol' && p.next_element.children.length > 2
      choices = CHOICE_REGEX_OL.match(p.next_element.to_s.xx)
      choices_array.push(choices[0])
      # puts(p_count.to_s.xx + " OL CHOICES: " + choices[0])
    elsif type == 'li'
      question = /(.*?(?=\n))/.match(p.to_s.xx)
      question_array.push(question.to_s)
      choices = /((?<=\n).*)/m.match(p.next_element.to_s.xx)
      choices_array.push(choices.to_s)
    end

    if EXPLANATION_REGEX.match(p.to_s.xx) && (ANSWER_SECTION_REGEX.match(page_html.to_s.xx).to_s.xx.include?(p.to_s.xx))
      explanation = EXPLANATION_REGEX.match(p.to_s.xx)
      explanation_array.push(explanation[0])
      # puts(p_count.to_s.xx + " EXPLANATION: " + explanation[0])
    elsif type == 'li' && /(.*?(?=\n))/.match(p.to_s.xx) && visited == false

      answers_link = page_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td > h2 > a')[0].attributes['href'].value

      puts(page_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td > h2 > a')[0].text)

      answer_page = Nokogiri::HTML(open(BASE_URL + answers_link)) #TO_DO: STOP OVERQUERYING

      answers_list = answer_page.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) > div.testq > ol > li')
      if answers_list.length > 1
        puts "LI-TYPE ANSWER SHEET"
        answers_list.each do | ans |
          explanation_array.push(ans.to_s.xx)
        end
        visited = true
      end

      answers_list = answer_page.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) > p')
      if answers_list.length > 1
        puts "P-TYPE ANSWER SHEET"
        answers_list.each do | ans |
          if EXPLANATION_REGEX.match(ans.to_s.xx)
            explanation = EXPLANATION_REGEX.match(ans.to_s.xx)
            explanation_array.push(explanation[0])
          end
        end
        visited = true
      end
    end

  end
  question_array.length.times do | index |
    json_array[index] = Question.new( question_array[index], choices_array[index], explanation_array[index], explanation_array[index] )
  end
  return json_array
end

def detect_links(page_html, test_name, useful_urls, visited_urls)
  if a_array = page_html.css('body > table > tr > td:nth-child(2) > table > tr:nth-child(2) > td:nth-child(1) a')

    a_array.each_with_index do | a, section_count |
      if CONTENT_REGEX.match(page_html.to_s.xx).to_s.xx.include?(p.to_s.xx) && BASE_URL_REGEX.match(a.to_s.xx)

        section_name = a.text
        section_link = a.attributes['href'].value
        section_dir = "#{DATA_DIR}/" + test_name + "/" + section_name
        section_fname = "#{section_dir}/#{File.basename(section_name)}.html"
        section_json = "#{section_dir}/#{File.basename(section_name)}.json"

        if !visited_urls.include?(section_link)

          visited_urls.push(section_link)

          stop_now = false

          begin
            if !EXTERNAL_URL_REGEX.match(section_link)
              section_html = Nokogiri::HTML(open(BASE_URL + section_link))
            else
              section_html = Nokogiri::HTML(open(section_link)) # OPENS TARGET PAGE
              puts("Newly opening #{section_link} for #{section_name}")
            end
          # RESCUE EXCEPTION
          rescue => e
            puts "Error: #{e}"
            sleep 5
            stop_now = true
          # WRITE TO FILE
          else
          # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
          ensure
            sleep 1.0 + rand
          end

          return if stop_now == true

          json_array = detect_test(section_html)

          if json_array.length > 0

            Dir.mkdir(section_dir) unless File.exists?(section_dir)

            if json_array[0].question == nil
              section_json = "#{section_dir}/no_questions.json"
            elsif json_array[0].choices == nil
              section_json = "#{section_dir}/no_choices.json"
            elsif json_array[0].answer == nil
              section_json = "#{section_dir}/no_answers.json"
            end

            File.open(section_fname, 'w'){|file| file.write(section_html)}
            puts "     -Saved SECTION #{section_count}: '#{section_name}' to (...#{section_fname[-20, 20]})"

            File.open(section_json, 'w'){|file| file.write(json_array.to_json)}
            puts "     -Saved SECTION JSON to #{section_json}"

            useful_urls.update({section_link => {'HTML' => section_html, 'JSON' => json_array}})

            puts "Useful URLs length updated to: #{useful_urls.length}"

          elsif json_array.length == 0
            puts "No useful information at #{section_link}"

          end

        elsif useful_urls[section_link]
          puts "          COPYING #{section_link} TO #{section_fname}"

          Dir.mkdir(section_dir) unless File.exists?(section_dir)
          if useful_urls[section_link]['JSON'][0].question == nil
            section_json = "#{section_dir}/no_questions.json"
          elsif useful_urls[section_link]['JSON'][0].choices == nil
            section_json = "#{section_dir}/no_choices.json"
          elsif useful_urls[section_link]['JSON'][0].answer == nil
            section_json = "#{section_dir}/no_answers.json"
          end
          File.open(section_fname, 'w'){|file| file.write(useful_urls[section_link]['HTML'])}
          File.open(section_json, 'w'){|file| file.write(useful_urls[section_link]['JSON'].to_json)}

        else
          puts("SECTION LINK IS NULL") if section_link == nil
          puts "#{section_link} was visited before and was useless."
        end
      end

    end

  end
end



test_links.each_with_index do |a, test_count|

  next if test_count < 75

  test_name = a.text
  test_link = a.attributes['href'].value

  test_dir = "#{DATA_DIR}/" + test_name
  Dir.mkdir(test_dir) unless File.exists?(test_dir)
  test_fname = "#{test_dir}/#{File.basename(test_name)}.html"
  test_json = "#{test_dir}/#{File.basename(test_name)}.json"

  stop_now = false

  begin
    test_html = Nokogiri::HTML(open(test_link)) # OPENS TARGET PAGE
  # RESCUE EXCEPTION
  rescue => e
    puts "Error: #{e}"
    sleep 5
    stop_now = true
  # WRITE TO FILE
  else
    File.open(test_fname, 'w'){|file| file.write(test_html)}
    puts " ...Success, saved TEST #{test_count}: '#{test_name}' to (#{test_fname})"
  # SLEEP A BIT SO THE SITE DOESN'T GET HAMMERED TOO HARD
  ensure
    sleep 1.0 + rand
  end

  next if stop_now == true

  json_array = detect_test(test_html)
  if json_array.length > 0
    File.open(test_json, 'w'){|file| file.write(json_array.to_json)}
    puts "\t...Success, saved NEW TEST JSON to #{test_json}"
  end
  visited_urls.push(test_link)

  detect_links(test_html, test_name, useful_urls, visited_urls)

end
