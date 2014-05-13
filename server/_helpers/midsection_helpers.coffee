@isMidSection = (file, fileTree) ->
  unless isTest(file)
    # Has a directory under it (/ but no .)
    midSectionsRegex = new RegExp(file + "\\/[^\\.]+?,")
    return midSectionsRegex.test(fileTree)


@processMidSection = (file, fileTree) ->

  # If TestMidSection with same filepath exists
  if findDocID(TestMidSections, filePath: file)
    existingPlaceholders()

  else # Get array of same test TestSection/TestMidsection children IDs one level down
    midSectionFileRegex = new RegExp("^" + file + "\\/[^\\.\\/]+$") # Directories one level under this (no . or /)
    parentTestDir = @getParentTestDir(file)
    parentTestID = findDocID(Tests, name: parentTestDir)
    # Get TestSections/TestMidSections with matching filepaths and same parent test
    childDirFields = {
      inTest: parentTestID,
      filePath: {$regex: midSectionFileRegex}
    }
    console.log "Query fields are: " + JSON.stringify(childDirFields) + midSectionFileRegex
    childrenIDs = []
    findTS = findDocIDs(TestSections, childDirFields)
    childrenIDs = childrenIDs.concat findTS if findTS
    findTMS = findDocIDs(TestMidSections, childDirFields)
    childrenIDs = childrenIDs.concat findTMS if findTMS

    if childrenIDs.length > 0
      insertedPlaceholders()
      placeholderID = insertDoc(TestMidSections, {filePath: file, inTest: parentTestID, children: childrenIDs})
      # Make it parent of children in that array, set relationship to test
      updateDocArray(TestMidSections, placeholderID, 'children', childrenIDs)
      updateDocs(TestSections, {_id: {$in: childrenIDs}}, {parent: placeholderID})
      updateDocs(TestMidSections, {_id: {$in: childrenIDs}}, {parent: placeholderID})
      setIfTestParent(TestMidSections, parentTestDir, parentTestID, placeholderID, file)

    else
      console.log "Midsection has no children. Query fields: " + JSON.stringify(childDirFields)

  # Give it an order


