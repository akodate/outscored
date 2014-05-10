@isQuestion = (file, fileTree) ->
  if QUESTION_REGEX.test(file)
    return isValidQuestion(file)

# Checks if question file is valid
@isValidQuestion = (file) ->
  # If JSON returns file to JSON
  if isJSONFile(file)
    questions = parseJSONFile(file)
    question = questions[0]
    # Has necessary question fields?
    if question.question && question.choices && question.answer
      return true
    else
      return false
  else
    return false