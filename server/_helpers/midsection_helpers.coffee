@isMidSection = (file, fileTree) ->
  unless isTest(file)
    # Has a directory under it (/ but no .)
    midSectionsRegex = new RegExp("^" + file + "\\/[^\\.]+?$")
    return midSectionsRegex.test(fileTree)


@processMidsections = (file, fileTree) ->
  # If TestMidSection with same filepath exists
  if findDocID(TestMidsections, filePath: file)
    existingCount()
  else
    # Get array of same test TestSection/TestMidsection children IDs one level down
    # Find directories one level under this (no . or /)
    midSectionFileRegex = new RegExp("^" + file + "\\/[^\\.\\/]+$")
    # Get TestSections/TestMidSections with those filepaths
    childDirFields = {
      _id: {$in: testQuestionIDs },
      filePath: {$regex: sectionFileRegex}
    }


  # Get array of same test TestSection/TestMidsection children IDs one level down
  # Create new TestMidSection with filePath: file, inTest: parentTestID, children from that array
  # Make it parent of children in that array
  # @setIfTestParent(placeholderCollection, parentTestDir, parentTestID, placeholderID, file)
  # Give it an order