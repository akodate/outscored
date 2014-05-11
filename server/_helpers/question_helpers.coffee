@isQuestion = (file, fileTree) ->
  if QUESTION_REGEX.test(file)
    return @isValidQuestion(file)

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

@processQuestions = (file, collection) ->
  for question in parseJSONFile(file)
    originalID = findDocID(collection, question)
    if originalID # Original already exists
      existingCount()
    else # Create original
      insertedCount()
      originalID = insertDoc(collection, question)
    # Unless test already points to that original (meaning placeholder exists)
    unless findPlaceholder(collection, file, originalID)
      # Point test to original and add placeholder
      insertPlaceholder(collection, file, originalID)

