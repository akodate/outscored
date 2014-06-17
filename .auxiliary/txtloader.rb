require 'json'
require 'pry'
require 'active_support/all'

# BEFORE RUNNING: Save Excel as UTF-16 .txt then save as UTF-8 in Sublime

SOURCE_DIR = "txt"
DATA_DIR = "assets"
Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)
TEST_FILE = '第二種衛生管理者試験.txt'
TEST_NAME = '第二種衛生管理者試験'

file = File.open("#{SOURCE_DIR}/#{TEST_FILE}", "r").read
puts file[0..50]

def parse(file)
  item = file.match(/.*?\t/)
  file = item.post_match
  return item.to_s.strip, file
end

def parse_end(file, test)
  item = file.match(/.*?(?=#{test[0..10]})/)
  file = item.post_match
  return item.to_s.strip, file
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
  if file.match(/.*?(?=#{test[0..10]})/)
    explanation, file = parse_end(file, test)
  else
    file = nil
  end

  choices = question.scan(/<br>\d:.*?(?=<br>|\z)/)
  question = question.match(/.*?(?=<br>\d:)/).to_s.strip.gsub(/問\d+\s*/, '')
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

  question_arr[count] = {}
  question_arr[count]['question'] = question
  question_arr[count]['choices'] = choices
  question_arr[count]['selections'] = selections
  question_arr[count]['answer'] = answer
  question_arr[count]['explanation'] = explanation
  question_arr[count]['section'] = section
  question_arr[count]['tags'] = [].push(year)
  count += 1

end

binding.pry

question_arr.each do |question|
  section_dir = "#{test_dir}/#{question.first.gsub(/\*/, '').gsub(/\//, '|')}"
  Dir.mkdir(section_dir) unless File.exists?(section_dir)
  puts "\t...Saved question as #{section_dir}"
  save_json(question, section_dir)
end

def save_json(question, section_dir)
  arr = []
  question[1]['questions'].each_with_index do |question, i|
    arr[i] = {}
    arr[i]['question'] = question[1]['questions'][i]
    arr[i]['choices'] = question[1]['choices'][i]
    arr[i]['selections'] = question[1]['selections'][i]
    arr[i]['answer'] = question[1]['answers'][i]
    arr[i]['explanation'] = question[1]['explanations'][i]
  end
  json_file = "#{section_dir}/#{question.first.gsub(/\*/, '').gsub(/\//, '|')}.json"
  File.open(json_file, 'w'){|file| file.write(arr.to_json)}
  puts "\t...Saved QUESTIONS as #{json_file}"
end