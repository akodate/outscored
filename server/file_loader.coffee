if Tests.find().fetch().length != 68

  COLLECTION_TYPES = [Tests, Questions, Sections, MidSections]

  testFileTree = new Glob('**/**/*', {debug: false, cwd: '/Users/alex/Projects/outscored/private'}, (err, matches) -> )
  # testFileTree = new Glob('**/**/*', {debug: false, '../../../programs/server/assets/app'}, (err, matches) -> )

  console.log(testFileTree.length + ' Files')

  # Returns array of file paths for Tests, Questions, Sections, and Midsections sequentially
  checkType = (fileTree) ->
    runCount = 0
    COLLECTION_TYPES.forEach((collection) ->
      typeArray = fileTree.filter((file) ->
        switch collection
          when Tests
            isTest(file)
          when Questions
            isQuestionFile(file)
          when Sections
            isSection(file, fileTree)
          when MidSections
            isMidSection(file, fileTree)
      )
      console.log typeArray.length + ' ' + collection._name.capitalize()
      processType(typeArray, collection, fileTree)
    )

  # Checks if file (or directory) is unique
  processType = (typeArray, collection, fileTree) ->
    countReset()
    for file in typeArray
      switch collection
        when Tests
          if processTest(file, collection)
            insertedCount()
          else
            existingCount()
        when Questions
          questionNumber = 0
          for question in parseJSONFile(file)
            if isValidQuestion(question)
              questionNumber += 1
              question = filterQuestion(question)
              processQuestion(collection, question, file, questionNumber)
        when Sections
          processSection(file, fileTree, collection)
        when MidSections
          processMidSection(file, fileTree)

    console.log collection._name.capitalize() + ' originals found ' + (existingCount() - 1) + 'times'
    console.log collection._name.capitalize() + ' originals inserted ' + (insertedCount() - 1) + 'times'
    console.log collection._name.capitalize() + ' placeholders found ' + (existingPlaceholders() -  1) + 'times'
    console.log collection._name.capitalize() + ' placeholders inserted ' + (insertedPlaceholders() - 1) + 'times'

  checkType(testFileTree)

  markBlankTests()
  console.log('Checked')
  console.log process.env.PWD
