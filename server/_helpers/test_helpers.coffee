@isTest = (file, fileTree) ->
  return TEST_REGEX.test(file)

@findTestByName = (testName) ->
  Tests.findOne(name: testName)

@insertTest = (fields) ->
  ins = Tests.insert(fields)
  console.log "Inserted test with ID " + ins + " and the following fields:"
  console.log fields
  return ins

@processTest = (file, collection) ->
  if findDoc(collection, {name: file})
    return false
  else
    insertTest(name: file)