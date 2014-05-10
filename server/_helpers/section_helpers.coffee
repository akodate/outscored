@isSection = (file, fileTree) ->
  # Unless test directory
  unless isTest(file)
    # Has file inside?
    sectionsRegex = (new RegExp(file + "\\/[^\\/]+\\."))
    return sectionsRegex.test(fileTree)

@insertSection = (fields) ->
  Sections.insert(fields)
  console.log "Inserted section: " + fields