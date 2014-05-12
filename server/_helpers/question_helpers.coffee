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

@processQuestion = (collection, question, file) ->
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

