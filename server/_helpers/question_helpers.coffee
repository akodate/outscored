# Answer regexes
# ANSWER_REGEX = /[A-Z0-9]/

# Choices regexes
# LIST_REGEX = /<li>(.|\n)*<li>/
# LIST_COUNT_REGEX = /<li>/g
# ROMAN_REGEX = /I[\.:].*\n\S{0,10}II[\.:]/

# UPPERCASE_REGEX = /A[\.:].*\n\S{0,10}B[\.:]/
# UPPERCASE_COUNT_REGEX = /(?:\n\S{0,10})([B-Z])(?:[\.:])/g
# LOWERCASE_REGEX = /a[\.:].*\n\S{0,10}b[\.:]/
# LOWERCASE_COUNT_REGEX = /(?:\n\S{0,10})([b-z])(?:[\.:])/g

# JP regexes
JP_DIGIT_REGEX = /^(\d):/
JP_PARENTH_REGEX = /^（(\d)）/
JP_CIRCLE_REGEX = /^[①②③④]/

@isQuestionFile = (file) ->
  if QUESTION_REGEX.test(file)
    if isJSONFile(file)
      return true

# Checks if question file is valid
@isValidQuestion = (question) ->
  # Has necessary question fields?
  if question.question && question.choices && question.choices[0] && question.answer
    return true
  else
    console.log '*******************************'
    console.log '*******************************'
    console.log '*******************************'
    console.log 'QUESTION: ' + question.question
    console.log 'CHOICES: ' + question.choices
    console.log 'ANSWER: ' + question.answer
    console.log '*******************************'
    console.log '*******************************'
    console.log '*******************************'
    return false

@filterQuestion = (question) ->
  # question.answer = filterAnswer(question.answer)
  if typeof question.choices == 'string'
    question.choices = question.choices.split('<br>').filter((n) -> n != '')
  else # Expand one digit answers and strip numbers from choices (JP questions)
    firstChoice = question.choices[0].replace(/^\w*<br>*/, '')
    if question.answer.match(/\d/) && (firstChoice.match(JP_DIGIT_REGEX) || firstChoice.match(JP_PARENTH_REGEX) || firstChoice.match(JP_CIRCLE_REGEX))
      question = expandAnswer(question)
      question = filterChoices(question)
  # question.selections = filterChoices(question.choices)
  return question

@processQuestion = (collection, question, file, questionNumber) ->
  originalID = findDocID(collection, question)
  if originalID # Original already exists
    existingCount()
  else # Create original
    insertedCount()
    originalID = insertDoc(collection, question)
  # Unless test already points to that original (meaning placeholder exists)
  unless findPlaceholder(collection, file, originalID)
    # Point test to original and add placeholder
    insertPlaceholder(collection, file, originalID, questionNumber)

@expandAnswer = (question) ->
  choices = question.choices
  answer = question.answer
  for choice in choices
    choice = choice.replace(/^\w*<br>*/, '')
    if answer == processSelection(choice)
      answer = choice.replace(/^\w*<br>*/, '')
      answer = answer.replace(JP_DIGIT_REGEX, '')
      answer = answer.replace(JP_PARENTH_REGEX, '')
      question.answer = answer.replace(JP_CIRCLE_REGEX, '')
  return question

@processSelection = (choice) ->
  if choice.match(JP_DIGIT_REGEX)
    choice.match(JP_DIGIT_REGEX)[1]
  else if choice.match(JP_PARENTH_REGEX)
    choice.match(JP_PARENTH_REGEX)[1]
  else if choice.match(JP_CIRCLE_REGEX)
    selection = choice.match(JP_CIRCLE_REGEX)[0]
    switch selection
      when '①' then '1'
      when '②' then '2'
      when '③' then '3'
      when '④' then '4'
      else selection

@filterChoices = (question) ->
  for choice, i in question.choices
    choice = choice.replace(/^\w*<br>*/, '')
    choice = choice.replace(JP_DIGIT_REGEX, '')
    choice = choice.replace(JP_PARENTH_REGEX, '')
    question.choices[i] = choice.replace(JP_CIRCLE_REGEX, '')
  return question

# filterAnswer = (answer) ->
#   if ANSWER_REGEX.exec(answer)
#     answer = ANSWER_REGEX.exec(answer)[0]
#   else
#     answer = "COULD NOT READ ANSWER"
#   return answer

# filterChoices = (choices) ->
#   # Checks for and counts <li> instances
#   selections = []
#   if LIST_REGEX.test(choices)
#     selections = choices.match(LIST_COUNT_REGEX)
#     # Creates alphabet choices from matches
#     for selection, i in selections
#       selections[i] = String.fromCharCode('A'.charCodeAt() + i)
#   else if ROMAN_REGEX.test(choices)
#     selections = ["ROMAN"]
#   else if UPPERCASE_REGEX.test(choices)
#     selections.push('A')
#     while selection = UPPERCASE_COUNT_REGEX.exec(choices)
#       selections.push(selection[1])
#   else if LOWERCASE_REGEX.test(choices)
#     selections.push('a')
#     while selection = LOWERCASE_COUNT_REGEX.exec(choices)
#       selections.push(selection[1])
#   if selections
#     return selections
#   else
#     console.log "Choices: " + choices + "\nSelections: " + selections
#     debugger
#     return false
