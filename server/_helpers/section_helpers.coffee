@isSection = (file, fileTree) ->
  # Unless test directory
  unless isTest(file)
    # Has file inside?
    sectionsRegex = new RegExp(file + "\\/[^\\/]+\\.")
    return sectionsRegex.test(fileTree)

@findSameSection = (sectionQuestionIDs) ->
  originalID = findDocID(Sections, hasQuestions: sectionQuestionIDs)

@findSectionQuestionIDs = (file, fileTree) ->
  sectionQuestionIDs = []
  # Get all question files in section
  sectionFileRegex = new RegExp("^" + file + "\\/[^\\/]+\\.")
  questionFiles = fileTree.filter (file) -> sectionFileRegex.test(file)
  # Filter out non-JSON files
  for questionFile in questionFiles
    if isQuestionFile(questionFile)
      questions = parseJSONFile(questionFile)
      # Filter out invalid questions
      for question in questions
        if isValidQuestion(question)
          sectionQuestionIDs.push(question)
  return sectionQuestionIDs

@processSection = (file, fileTree, collection) ->
  # Is there a section with the same questions as this one?
  sectionQuestionIDs = @findSectionQuestionIDs(file, fileTree)
  originalID = @findSameSection(sectionQuestionIDs)
  if originalID # Original already exists
    existingCount()
  else # Create original
    insertedCount()
    originalID = insertDoc(collection, {hasQuestions: sectionQuestionIDs})
  # Unless test already points to that original (meaning placeholder exists)
  unless findPlaceholder(collection, file, originalID)
    # Point test to original and add placeholder
    insertPlaceholder(collection, file, originalID)