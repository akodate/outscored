require 'json'
require 'pry'
require 'active_support/all'

# Use UTF-8 converted tab-delimited sheets

SOURCE_DIR = "raw"
DATA_DIR = "new-assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

puts "Test name?"
TEST_NAME = gets.chomp
TEST_FILE = TEST_NAME + '.txt'
puts TEST_FILE

TEST_DIR = "#{DATA_DIR}/#{TEST_NAME}"
Dir.mkdir(TEST_DIR) unless File.exists?(TEST_DIR)

file = File.open("#{SOURCE_DIR}/#{TEST_FILE}", "r").read
puts file[0..50]

def parse(file)
  item = file.match(/(?:\t|\r|^)([^\r\t]*)/)
  file = item.post_match
  item = item[1] || ''
  # binding.pry
  return item.to_s.strip, file
end

question_arr = []
count = 0

while file != ''

  test, file = parse(file)
  section, file = parse(file)
  number, file = parse(file)
  question, file = parse(file)
  choices, file = parse(file)
  answer, file = parse(file)
  explanation, file = parse(file)
  tags, file = parse(file)

  choices = choices.split('|||')

  puts '*' * 500
  puts test
  puts section
  puts number
  puts question
  puts choices
  puts answer
  puts explanation
  puts tags
  puts '*' * 500

  question_arr[count] = {}
  question_arr[count]['section'] = section
  question_arr[count]['number'] = number
  question_arr[count]['question'] = question
  question_arr[count]['choices'] = choices
  question_arr[count]['answer'] = answer
  question_arr[count]['explanation'] = explanation
  question_arr[count]['tags'] = tags
  count += 1

  # if count == 101
  #   binding.pry
  # end

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
