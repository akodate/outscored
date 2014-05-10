COLLECTION_TYPES = [Tests, Questions, Sections, MidSections]

# testData = JSON.parse(Assets.getText('ACT Practice Test/Advanced Algebra/Advanced Algebra.json'))
# console.log(JSON.stringify(testData).substr(0,100))

# if Tests.findOne(testData)
#   console.log('Already exists')
# else
#   console.log('Inserted' + Tests.insert(testData))


testFileTree = new Glob('**/**/*', {debug: false, cwd: '/Users/alex/Projects/outscored/private'}, (err, matches) -> )

console.log(testFileTree.length + ' Files')

# Returns array of file paths for Tests, Questions, Sections, and Midsections sequentially
checkType = (fileTree) ->
  COLLECTION_TYPES.forEach((collection) ->
    typeArray = fileTree.filter((file) ->
      switch collection
        when Tests
          collection = Tests
          isTest(file, fileTree)
        when Questions
          collection = Questions
          isQuestion(file, fileTree)
        when Sections
          collection = Sections
          isSection(file, fileTree)
        when MidSections
          collection = MidSections
          isMidSection(file, fileTree)
    )
    console.log typeArray.length + ' ' + collection._name.capitalize()
    isUnique(typeArray, collection)
  )

# Checks if file (or directory) is unique
isUnique = (typeArray, collection) ->
  insertedCount = 0
  existingCount = 0
  for file in typeArray
    switch collection
      when Tests
        if isUniqueTest(file)
          insertedCount += 1
          insertTest(name: file)
        else
          existingCount += 1
      # when Questions
      #   for question in getQuestionArray(file)
      #     if isUniqueQuestion(question)
      #       insertQuestion(question)
      #     else
      #       return
      when Sections
        if isUniqueSection(file)
          return
      when MidSections
        if isUniqueMidSection(file)
          return
  console.log collection._name.capitalize() + ' inserted: ' + insertedCount
  console.log collection._name.capitalize() + ' found: ' + existingCount

# SECTIONS
# Trait: Has / and question file
  # If no sections have same question set
    # Save original, save placeholder, point to questions, make questions point to it
  # Else
    # Save placeholder, point to questions, make questions point to it
  # If has parent test
    # Point to parent test, make parent test point to it
isUniqueSection = (sectionDir) ->
  # Tests.findOne(sectionDir)

# MIDSECTIONS
# Trait: has / but no question file
  # If no midsections have the same section/midsection names
    # Save original, save placeholder, point to sections/midsections, make sections/midsections point to it
  # Else
    # Save placeholder, point to sections/midsections
  # If has parent test
      # Point to parent test, make parent test point to it
isUniqueMidSection = (midSectionDir) ->
  # Tests.findOne(midSectionDir)



checkType(testFileTree)
console.log('Checked')


  # IS VALID (ARRAY, COLLECTION)
    # IS UNIQUE (ARRAY, COLLECTION)
      # SAVE ORIGINAL (OBJECT, CLASS)
      # SAVE PLACEHOLDER (OBJECT, CLASS)
  # MAKE THIS POINT TO X (OBJECT, OTHEROBJECTS, CLASS)
  # MAKE X POINT TO THIS (OBJECT, OTHEROBJECTS, CLASS)
  # HAS PARENT TEST (OBJECT)
