@JSON_REGEX = /^.*\.json$/ # Ends with '.json'
@TEST_REGEX = /^[^\/]+$/ # No /
@QUESTION_REGEX = /^.*\.+.*$/ # has .
@SECTION_REGEX = /.*/ # Placeholder, dynamically generated
@MIDSECTION_REGEX = /.*/ # Placeholder, dynamically generated
@IS_PARENT_TEST_REGEX = /^[^\/]+\/[^\/]+$/ # One slash on the whole line
@PARENT_TEST_REGEX = /^[^\/]+/ # Up until first /
@PARENT_REGEX = /.*(?=\/)/
@CHILD_REGEX = /^file[^\/]+/ # Placeholder, dynamically generated

insertedCount = 0
existingCount = 0
insertedPlaceholders = 0
existingPlaceholders = 0

@String.prototype.capitalize = () ->
  return this[0].toUpperCase() + this[1..-1]

# Is JSON?
@isJSONFile = (file) ->
  JSON_REGEX.test(file)

# Returns JSON object
@parseJSONFile = (file) ->
  return JSON.parse(Assets.getText(file))





# ===== FINDS =====

# Find any document
@findDoc = (collection, fields, options = {}) ->
  collection.findOne(fields, options)

# Find any document's ID
@findDocID = (collection, fields) ->
  col = collection.findOne(fields, {_id: 1})
  if col
    col._id

# Find any set of documents
@findDocs = (collection, fields, options = {}) ->
  collection.find(fields, options)

# Find any set of documents' IDs
@findDocIDs = (collection, fields) ->
  ids = []
  docs = collection.find(fields, {_id: 1})
  if docs
    for doc in docs
      ids.push[doc._id]
    return ids

# Find placeholder
@findPlaceholder = (collection, file, originalID) ->
  parentTestDir = @getParentTestDir(file)
  parentTest = @findDoc(Tests, {name: parentTestDir})
  # Does hasCollection field exist?
  hasCollection = parentTest['has' + collection._name.capitalize()]
  if hasCollection
    # Checks if identical question/section is already in parent test
    if originalID in hasCollection
      @existingPlaceholders()
      return true
    else
      return false
  else
    return false

# Get parent test directory
@getParentTestDir = (file) ->
  dir = @PARENT_TEST_REGEX.exec(file)
  if dir
    dir[0]

# Get parent directory
@getParentDir = (file) ->
  dir = @PARENT_REGEX.exec(file)
  if dir
    dir[0]





# ===== INSERTS =====

# Insert any document
@insertDoc = (collection, fields) ->
  insID = collection.insert(fields)
  console.log "Inserted ID:" + insID + " into " + collection._name.capitalize() + " with the following fields:"
  console.log fields
  return insID

# Inserts new placeholder
@insertPlaceholder = (collection, file, originalID) ->
  parentTestID = @setInTest(collection, originalID, file)
  # Create placeholder, point it to original, point it to test, save filepath
  fields = {original: originalID, inTest: parentTestID, filePath: file}
  placeholderCollection = @setPlaceholderCollection(collection)
  placeholderID = @insertDoc(placeholderCollection, fields)
  @insertedPlaceholders()
  # Point test to original and placeholder
  testField1 = {}
  testField2 = {}
  testField1['has' + collection._name.capitalize()] = originalID
  testField2['has' + placeholderCollection._name.capitalize()] = placeholderID
  @updateDocArraySingle(Tests, parentTestID, testField1)
  @updateDocArraySingle(Tests, parentTestID, testField2)
  # Point original to test
  @setInTest(collection, originalID, file)

  # Establish local placeholder relationships
  if collection == Questions
    # If parent directory IS test directory, establish parent/child relationship
    if @getParentTestDir(file) == @getParentDir(file)
      @updateDocArraySingle(Tests, parentTestID, { children: placeholderID })
      @updateDoc(Questions, placeholderID, { parent: parentTestID })
  else if collection == Sections
    # Find all placeholder questions in this test
    filteredParentTest = @findDoc({Tests, name: parentTestDir}, {hasTestQuestions: 1})
    testQuestionIDs = filteredParentTest.hasTestQuestions
    # Get IDs of questions that are children of this test and section
    childRegex = new Regexp("^" + file + "[^\\/]+")
    sectionQuestionFields = {inTest: filteredParentTest._id, filePath: childRegex}
    sectionQuestionIDs = @findDocIDs(TestQuestions, sectionQuestionFields)
    # Point section to questions and questions to section
    @updateDocArray(TestSections, placeholderID, 'children', sectionQuestionIds)
    @updateDocs(TestQuestions, {_id: {$in: sectionQuestionsIDs}}, {parent: placeholderID})
  else if collection == MidSections
    console.log "Not now...."





# ===== UPDATES =====

@updateDoc = (collection, id, fields) ->
  updNum = collection.upsert(id, {$set: fields})
  console.log "Updated ID:" + id + " in " + collection._name.capitalize() + " with the following fields:"
  console.log fields
  if updNum == 0
    throw 'Failed'
  return updNum

@updateDocArraySingle = (collection, id, fields) ->
  updNum = collection.upsert(id, {$addToSet: fields })
  console.log "Updated ID:" + id + " in " + collection._name.capitalize() + " by adding the following elements: "
  console.log fields
  if updNum == 0
    throw 'Failed'
  return updNum

@updateDocArray = (collection, id, field, array) ->
  updNum = collection.upsert(id, {$addToSet: {field: {$each: array} } })
  console.log "Updated ID:" + id + " in " + collection._name.capitalize() + " by adding this length array: \n" + array.length + "\nto the following field:"
  console.log field
  if updNum == 0
    throw 'Failed'
  return updNum

@updateDocs = (collection, selectors, fields) ->
  updNum = collection.upsert(selectors, fields, {multi: true})
  console.log "Updated " + collection._name.capitalize() + " using these selectors and fields: "
  console.log selectors
  console.log fields
  if updNum == 0
    throw 'Failed'
  return updNum



# ===== MISCELLANEOUS =====

@setPlaceholderCollection = (collection) ->
  switch collection
    when Questions
      TestQuestions
    when Sections
      TestSections
    when MidSections
      TestMidSections

@setInTest = (collection, ID, file) ->
  parentTestDir = @getParentTestDir(file)
  parentTestID = @findDocID(Tests, {name: parentTestDir})
  if @updateDocArraySingle(collection, ID, {inTest: parentTestID})
    parentTestID
  else
    false

@checkCount = ->
  count = insertedCount + existingCount + insertedPlaceholders + existingPlaceholders
  if count % 50 == 0
    console.log("========== Ran " + count + " times ==========")
  # if count > 1000
  #   throw 'Time to die.'

@insertedCount = ->
  @checkCount()
  insertedCount += 1

@existingCount = ->
  @checkCount()
  existingCount += 1

@insertedPlaceholders = ->
  @checkCount()
  insertedPlaceholders += 1

@existingPlaceholders = ->
  @checkCount()
  existingPlaceholders += 1

@countReset = ->
  insertedCount = 0
  existingCount = 0
  insertedPlaceholders = 0
  existingPlaceholders = 0
