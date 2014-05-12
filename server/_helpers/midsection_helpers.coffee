@isMidSection = (file, fileTree) ->
  # Has directory inside but no file?
  unless isTest(file)
    midSectionsRegex = new RegExp(file + "\\/[^\\.]+(?=,)")
    return midSectionsRegex.test(fileTree)




# MIDSECTIONS
# Trait: has / but no question file
  # If no midsections have the same section/midsection names
    # Save original, save placeholder, point to sections/midsections, make sections/midsections point to it
  # Else
    # Save placeholder, point to sections/midsections
  # If has parent test
      # Point to parent test, make parent test point to it
  # Tests.findOne(midSectionDir)