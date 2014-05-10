JSON_REGEX = /^.*\.json$/i
TEST_REGEX = /^[^\/]+$/i # No /
QUESTION_REGEX = /^.*\.+.*$/i # has .
SECTION_REGEX = /.*/ # Placeholder, dynamically generated
MIDSECTION_REGEX = /.*/ # Placeholder, dynamically generated
TYPE_REGEX_ARRAY = [TEST_REGEX, QUESTION_REGEX, SECTION_REGEX, MIDSECTION_REGEX]
collection = Tests

# testData = JSON.parse(Assets.getText('ACT Practice Test/Advanced Algebra/Advanced Algebra.json'))
# console.log(JSON.stringify(testData).substr(0,100))

# if Tests.findOne(testData)
#   console.log('Already exists')
# else
#   console.log('Inserted' + Tests.insert(testData))


testFileTree = new Glob('**/**/*', {debug: false, cwd: '/Users/alex/Projects/outscored/private'}, (err, matches) -> )

console.log(testFileTree.length)

# Returns array of file paths for Tests, Questions, Sections, and Midsections sequentially
checkType = (fileTree) ->
  TYPE_REGEX_ARRAY.forEach((regex, index) ->
    console.log('COME THIS FAR')
    typeArray = fileTree.filter((file) ->
      switch index
        when 0 # Tests
          collection = Tests
          isTest(file, fileTree, regex)
        when 1 # Questions
          collection = Questions
          isQuestion(file, fileTree, regex)
        when 2 # Sections
          collection = Sections
          isSection(file, fileTree, regex)
        when 3 # Midsections
          collection = MidSections
          isMidSection(file, fileTree, regex)
    )
    console.log collection._name
    console.log(typeArray.length)
    isUnique(typeArray, collection)
  )

isTest = (file, fileTree) ->
  return TEST_REGEX.test(file)

isQuestion = (file, fileTree, regex) ->
  if QUESTION_REGEX.test(file)
    return isValidQuestion(file)

isSection = (file, fileTree, regex) ->
  # Unless test directory
  unless isTest(file)
    # Has file inside?
    sectionsRegex = (new RegExp(file + "\\/[^\\/]+\\."))
    return sectionsRegex.test(fileTree)

isMidSection = (file, fileTree, regex) ->
  # Has directory inside but no file?
  unless isTest(file)
    midSectionsRegex = (new RegExp(file + "\\/[^\\.]+(?=,)"))
    return midSectionsRegex.test(fileTree)

# Checks if question file is valid
isValidQuestion = (file) ->
  # If JSON returns file to JSON
  questions = isJSON(file)
  if questions
    question = questions[0]
    # Has necessary question fields?
    if question.question && question.choices && question.answer
      return true
    else
      return false
  else
    return false

# Is JSON? Returns JSON object
isJSON = (file) ->
  if JSON_REGEX.test(file)
    questions = JSON.parse(Assets.getText(file))

# Checks if file (or directory) is unique
isUnique = (typeArray, collection) ->
  # for file in typeArray
  #   switch collection
  #     when Tests
  #       isUniqueTest(typeArray, collection)
  #     when Questions
  #       isUniqueQuestion(typeArray, collection)
  #     when Sections
  #       isUniqueSection(typeArray, collection)
  #     when MidSections
  #       isUniqueMidSection(typeArray, collection)

checkType(testFileTree)
console.log('Checked')


  # IS VALID (ARRAY, COLLECTION)
    # IS UNIQUE (ARRAY, COLLECTION)
      # SAVE ORIGINAL (OBJECT, CLASS)
      # SAVE PLACEHOLDER (OBJECT, CLASS)
  # MAKE THIS POINT TO X (OBJECT, OTHEROBJECTS, CLASS)
  # MAKE X POINT TO THIS (OBJECT, OTHEROBJECTS, CLASS)
  # HAS PARENT TEST (OBJECT)


# TESTS
# Trait: No /
  # If name is unique
    # Save original
  # Else do nothing

# QUESTIONS
# Trait: Has .
  # If fields are unique
    # Save original, save placeholder
  # Else
    # Save placeholder
  # If has parent test
    # Point to parent test, make parent test point to it

# SECTIONS
# Trait: Has / and question file
  # If no sections have same question set
    # Save original, save placeholder, point to questions, make questions point to it
  # Else
    # Save placeholder, point to questions, make questions point to it
  # If has parent test
    # Point to parent test, make parent test point to it

# MIDSECTIONS
# Trait: has / but no question file
  # If no midsections have the same section/midsection names
    # Save original, save placeholder, point to sections/midsections, make sections/midsections point to it
  # Else
    # Save placeholder, point to sections/midsections
  # If has parent test
      # Point to parent test, make parent test point to it

