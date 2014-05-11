@JSON_REGEX = /^.*\.json$/i # Ends with '.json'
@TEST_REGEX = /^[^\/]+$/i # No /
@QUESTION_REGEX = /^.*\.+.*$/i # has .
@SECTION_REGEX = /.*/ # Placeholder, dynamically generated
@MIDSECTION_REGEX = /.*/ # Placeholder, dynamically generated
@IS_PARENT_TEST_REGEX = /^[^\/]+\/[^\/]+$/ # One slash on the whole line
@PARENT_TEST_REGEX = /^[^\/]+/ # Up until first /
@CHILD_REGEX = /^file[^\/]+/ # Placeholder, dynamically generated

@String.prototype.capitalize = () ->
  return this[0].toUpperCase() + this[1..-1];

# Is JSON?
@isJSONFile = (file) ->
  JSON_REGEX.test(file)

# Returns JSON object
@parseJSONFile = (file) ->
  return JSON.parse(Assets.getText(file))




# Find any document
@findDoc = (collection, fields) ->
  collection.findOne(fields)

# Find placeholder
@findPlaceholder = (collection, fields, file, originalID) ->
  placeholderCollection = @setPlaceholderCollection(collection)
  parentTest = @findParentTest(file)
  # Checks if identical question/section is already in parent test
  if originalID in parentTest['has' + collection._name.capitalize()]
    return true
  # Inserts new placeholder
  else
    fields = {original: originalID, inTest: parentTest._id}
    placeholderID = insertDoc(placeholderCollection, fields)
    childFields = {
      childRegex = (new RegExp("^" + file + "[^\\/]+")
    }
    testFields = {
      'has' + collection._name.capitalize(): originalID,
      'has' + placeholderCollection._name.capitalize(): placeholderID
    }
    Tests.update(parentTest._id, testFields)
    @findParent
    testFields = {

    }
    Tests.update(parentTest)

# Find parent test
@findParentTest = (file) ->
  parentTestDir = @PARENT_TEST_REGEX.exec(file)
  findDoc(Tests, {name: parentTestDir})




# Insert any document
@insertDoc = (collection, fields) ->
  ins = collection.insert(fields)
  console.log "Inserted " + collection + " with ID " + ins + " and the following fields:"
  console.log fields
  return ins



# Set placeholder collection
@setPlaceholderCollection = (collection) ->
  switch collection
    when Questions
      TestQuestions
    when Sections
      TestSections
    when MidSections
      TestMidSections