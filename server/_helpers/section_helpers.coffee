@isSection = (file, fileTree) ->
  # Unless test directory
  unless isTest(file)
    # Has file inside?
    sectionsRegex = new RegExp(file + "\\/[^\\/]+\\.")
    return sectionsRegex.test(fileTree)

@processSection = (file, collection) ->
  originalID = findDocID(collection, {filePath: file})
  if originalID # Original already exists
    existingCount()
  else # Create original
    insertedCount()
    originalID = insertDoc(collection, {filePath: file})
  # Unless test already points to that original (meaning placeholder exists)
  unless findPlaceholder(collection, file, originalID)
    # Point test to original and add placeholder
    insertPlaceholder(collection, file, originalID)