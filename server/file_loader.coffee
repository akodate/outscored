COLLECTION_TYPES = [Tests, Questions, Sections, MidSections]

testFileTree = new Glob('**/**/*', {debug: false, cwd: '/Users/alex/Projects/outscored/private'}, (err, matches) -> )

console.log(testFileTree.length + ' Files')

# Returns array of file paths for Tests, Questions, Sections, and Midsections sequentially
checkType = (fileTree) ->
  runCount = 0
  COLLECTION_TYPES.forEach((collection) ->
    typeArray = fileTree.filter((file) ->
      switch collection
        when Tests
          isTest(file, fileTree)
        when Questions
          isQuestion(file, fileTree)
        when Sections
          isSection(file, fileTree)
        when MidSections
          isMidSection(file, fileTree)
    )
    console.log typeArray.length + ' ' + collection._name.capitalize()
    isUnique(typeArray, collection)
  )

# Checks if file (or directory) is unique
isUnique = (typeArray, collection) ->
  countReset()
  for file in typeArray
    switch collection
      when Tests
        if processTest(file, collection)
          insertedCount()
        else
          existingCount()
      when Questions
        processQuestions(file, collection)
      when Sections
        processSection(file, collection)
      # when MidSections
      #   if midSectionExists(file)
      #     return
  console.log collection._name.capitalize() + ' originals found: ' + (existingCount() - 1)
  console.log collection._name.capitalize() + ' originals inserted: ' + (insertedCount() - 1)
  console.log collection._name.capitalize() + ' placeholders found: ' + (existingPlaceholders() - 1)
  console.log collection._name.capitalize() + ' placeholders inserted: ' + (insertedPlaceholders() - 1)

# MIDSECTIONS
# Trait: has / but no question file
  # If no midsections have the same section/midsection names
    # Save original, save placeholder, point to sections/midsections, make sections/midsections point to it
  # Else
    # Save placeholder, point to sections/midsections
  # If has parent test
      # Point to parent test, make parent test point to it
  # Tests.findOne(midSectionDir)

checkType(testFileTree)
console.log('Checked')
