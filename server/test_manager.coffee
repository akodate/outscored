TYPE_REGEX_ARRAY = [/^[^\/]+$/i, /^.*\.+.*$/i, /.*/, /.*/] #　No /, has ., *, *
JSON_REGEX = /^.*\.json$/i

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
    fileArray = fileTree.filter((file) ->
      switch index
        when 0 # Tests
          collection = Tests
          return regex.test(file)
        when 1 # Questions
          collection = Questions
          if regex.test(file)
            return isValidQuestion(file)
        when 2 # Sections
          collection = Sections
          # Is not a test directory?
          unless TYPE_REGEX_ARRAY[0].test(file)
            # Has file inside?
            sectionsRegex = (new RegExp(file + "\\/[^\\/]+\\."))
            return sectionsRegex.test(fileTree)
        when 3 # Midsections
          collection = MidSections
          # Has directory inside but no file?
          midSectionsRegex = (new RegExp(file + "\\/[^\\.]+\z"))
          return midSectionsRegex.test(fileTree)
    )
    console.log collection._name
    console.log(fileArray.length)
  )

# Checks if question file is valid
isValidQuestion = (file) ->
  # If JSON returns file to JSON
  questions = isJSON(file)
  if questions
    question = questions[0]
    # Has necessary question fields?
    if question.question && question.choices && question.answer
      console.log 'Valid file: ' + file
      return true
    else
      return false
  else
    return false

# Is JSON? Returns JSON object
isJSON = (file) ->
  if JSON_REGEX.test(file)
    questions = JSON.parse(Assets.getText(file))

# Checks if file is unique
# isUnique = (fileArray, collection)

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

