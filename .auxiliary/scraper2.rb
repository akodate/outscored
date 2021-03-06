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
  test[section]['selections'] ||= []
  test[section]['answers'] ||= []
  test[section]['explanations'] ||= []

  puts "*** QUESTION NUMBER " + (test[section]['questions'].count + 1).to_s + " ***"
  puts "Section: " + section
  puts "Question: " + (test[section]['questions'].push find_question(mech)).last.to_s
  puts "Choices: " + (test[section]['choices'].push find_choices(mech)).last.to_s
  puts "Selections: " + (test[section]['selections'].push find_selections(mech)).last.to_s
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
  selector = '.answer, .answerred'
  if mech.page.search(selector)
    arr = []
    mech.page.search(selector).each do |choice|
      arr.push choice.text if choice.text != ''
    end
    return arr.join('<br>')
  end
end

def find_selections(mech)
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
    return mech.page.search(selector)[0].text
  end

  # if mech.page.search(selector)
  #   # Gets number of right choice from nth child
  #   num = mech.page.search(selector)[0].css_path.scan(ANSWER_REGEX)[1].to_i - 2

  #   num -= 1
  #   let = 'A'
  #   num.times do
  #     let.next!
  #   end
  #   return let

  # end
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
    section_dir = "#{test_dir}/#{section.first.gsub(/\*/, '').gsub(/\//, '|')}"
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
    arr[i]['selections'] = section[1]['selections'][i]
    arr[i]['answer'] = section[1]['answers'][i]
    arr[i]['explanation'] = section[1]['explanations'][i]
  end
  json_file = "#{section_dir}/#{section.first.gsub(/\*/, '').gsub(/\//, '|')}.json"
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
    test_name = mech.page.search('.examtitle').text.gsub(/\*/, '').gsub(/\//, '|')
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
