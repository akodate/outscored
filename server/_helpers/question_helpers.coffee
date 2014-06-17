# Answer regexes
ANSWER_REGEX = /[A-Z0-9]/

# Choices regexes
LIST_REGEX = /<li>(.|\n)*<li>/
LIST_COUNT_REGEX = /<li>/g
ROMAN_REGEX = /I[\.:].*\n\S{0,10}II[\.:]/

UPPERCASE_REGEX = /A[\.:].*\n\S{0,10}B[\.:]/
UPPERCASE_COUNT_REGEX = /(?:\n\S{0,10})([B-Z])(?:[\.:])/g
LOWERCASE_REGEX = /a[\.:].*\n\S{0,10}b[\.:]/
LOWERCASE_COUNT_REGEX = /(?:\n\S{0,10})([b-z])(?:[\.:])/g

@isQuestionFile = (file) ->
  if QUESTION_REGEX.test(file)
    if isJSONFile(file)
      return true

# Checks if question file is valid
@isValidQuestion = (question) ->
  # Has necessary question fields?
  if question.question && question.choices && question.answer
    return true
  else
    return false

@filterQuestion = (question) ->
  question.answer = filterAnswer(question.answer)
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

filterAnswer = (answer) ->
  if ANSWER_REGEX.exec(answer)
    answer = ANSWER_REGEX.exec(answer)[0]
  else
    answer = "COULD NOT READ ANSWER"
  return answer

filterChoices = (choices) ->
  # Checks for and counts <li> instances
  selections = []
  if LIST_REGEX.test(choices)
    selections = choices.match(LIST_COUNT_REGEX)
    # Creates alphabet choices from matches
    for selection, i in selections
      selections[i] = String.fromCharCode('A'.charCodeAt() + i)
  else if ROMAN_REGEX.test(choices)
    selections = ["ROMAN"]
  else if UPPERCASE_REGEX.test(choices)
    selections.push('A')
    while selection = UPPERCASE_COUNT_REGEX.exec(choices)
      selections.push(selection[1])
  else if LOWERCASE_REGEX.test(choices)
    selections.push('a')
    while selection = LOWERCASE_COUNT_REGEX.exec(choices)
      selections.push(selection[1])
  if selections
    return selections
  else
    console.log "Choices: " + choices + "\nSelections: " + selections
    debugger
    return false
