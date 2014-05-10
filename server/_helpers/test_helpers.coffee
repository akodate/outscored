@isTest = (file, fileTree) ->
  return TEST_REGEX.test(file)

@findTestByName = (testName) ->
  Tests.findOne(name: testName)

@isUniqueTest = (testDir) ->
  !findTestByName(testDir)