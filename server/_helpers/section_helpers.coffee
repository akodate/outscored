@isSection = (file, fileTree) ->
  # Unless test directory
  unless isTest(file)
    # Has either file or nothing inside
    sectionsRegex = new RegExp(file + "\\/[^\\/]+\\.")
    return sectionsRegex.test(fileTree) || (!isMidSection(file, fileTree) && !QUESTION_REGEX.test(file))

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
          questionID = findDocID(Questions, question)
          sectionQuestionIDs.push(questionID)
  if sectionQuestionIDs.length == 0
    false
  else
    sectionQuestionIDs

@processSection = (file, fileTree, collection) ->
  # Does the section have questions?
  sectionQuestionIDs = @findSectionQuestionIDs(file, fileTree)
  # Is there a section with the same questions as this one?
  if sectionQuestionIDs
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
  else
    @processBlankSection(file)

@processBlankSection = (file) ->
  if findDocID(TestSections, filePath: file)
    existingPlaceholders()
    console.log "Blank test section '" + file + "' already exists"
  else
    parentTestDir = @getParentTestDir(file)
    parentTestID = findDocID(Tests, name: parentTestDir)
    if parentTestID
      placeholderID = insertDoc(TestSections, filePath: file, inTest: parentTestID, blank: true)
      setIfTestParent(TestSections, parentTestDir, parentTestID, placeholderID, file)
      insertedPlaceholders()
      console.log "Processed " + file + " as blank section"
    else
      throw "Can't insert blank: " + file
