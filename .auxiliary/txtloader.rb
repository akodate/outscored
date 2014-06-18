require 'json'
require 'pry'
require 'active_support/all'

# BEFORE RUNNING: Save Excel as UTF-16 .txt then save as UTF-8 in Sublime
# AFTER RUNNING: Copy folder tree into /private, copy a working file tree in /private, rename its files, copy-paste json contents to renamed files, move renamed files into folder tree

SOURCE_DIR = "txt"
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

puts "Test name?"
TEST_NAME = gets.chomp
TEST_FILE = TEST_NAME + '.txt'
puts TEST_FILE

# TEST_FILE = '第二種衛生管理者試験.txt'
# TEST_NAME = '第二種衛生管理者試験'
TEST_DIR = "#{DATA_DIR}/#{TEST_NAME}"
Dir.mkdir(TEST_DIR) unless File.exists?(TEST_DIR)

file = File.open("#{SOURCE_DIR}/#{TEST_FILE}", "r").read
puts file[0..50]

def parse(file)
  item = file.match(/.*?\t/)
  file = item.post_match
  return item.to_s.strip, file
end

def parse_end(file, test)
  item = file.match(/.*?(?=\r第)/)
  file = item.post_match
  return item.to_s.strip, file
end

def clean(item)
  return item.gsub(/\"/, '').strip.gsub(/\A　*/, '')
end

question_arr = []
count = 0

while file

  test, file = parse(file)
  year, file = parse(file)
  section, file = parse(file)
  number, file = parse(file)
  question, file = parse(file)
  selections, file = parse(file)
  answer, file = parse(file)
  if file.match(/.*?(?=\r第)/)
    explanation, file = parse_end(file, test)
  else
    file = nil
  end

  if question.match(/.*?(?=<br>(?:\d:|（))/)
    choices = question.scan(/<br>(?:\d:|（).*?(?=<br>|\z)/)
    question = question.match(/.*?(?=<br>(?:\d:|（))/).to_s.strip.gsub(/問.*?(　|\s+)/, '')
  else
    choices = []
  end

  selections = selections.gsub(/\"/, '').split(',')

  puts test
  puts year
  puts section
  puts number
  puts question
  puts choices
  puts selections
  puts answer
  puts explanation
  puts '*' * 500

  choices[-1] = clean(choices[-1]) if choices != []
  question = clean(question)
  explanation = clean(explanation)

  question_arr[count] = {}
  question_arr[count]['question'] = question
  question_arr[count]['choices'] = choices
  question_arr[count]['selections'] = selections
  question_arr[count]['answer'] = answer
  question_arr[count]['explanation'] = explanation
  question_arr[count]['section'] = section
  question_arr[count]['tags'] = [].push(year)
  count += 1

  if count == 315
    binding.pry
  end

end

test_obj = {}
question_arr.each do |question|
  if test_obj[question['section']]
    test_obj[question['section']].push(question)
  else
    test_obj[question['section']] = [].push(question)
  end
end

test_obj.each do |section|
  section_dir = "#{DATA_DIR}/#{TEST_NAME}/#{section.first.gsub(/\//, '|')}"
  Dir.mkdir(section_dir) unless File.exists?(section_dir)
  puts "\t...Saving question in #{section_dir}"

  json_file = "#{section_dir}/#{section.first.gsub(/\//, '|')}.json"
  File.open(json_file, 'w'){|file| file.write(section[1].to_json)}
  puts "\t...Saved QUESTIONS as #{json_file}"
end
