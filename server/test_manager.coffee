fileName = ""
TYPE_REGEX_ARRAY = [/^[^\/]+$/i, /^.*\.+.*$/i, /.*/, /.*/]

testData = JSON.parse(Assets.getText('ACT Practice Test/Advanced Algebra/Advanced Algebra.json'))
console.log(JSON.stringify(testData).substr(0,100))


testFileTree = new Glob('**/**/*', {debug: false, cwd: '/Users/alex/Projects/outscored/private'}, (err, matches) -> )

# for file in testFileTree
#   console.log('File: ' + file)

console.log(testFileTree.length)

if Tests.findOne(testData)
  console.log('Already exists')
else
  console.log('Inserted' + Tests.insert(testData))

# DO SEQUENTIALLY:

# METHODS:

# CHECK TYPE SEQUENTIALLY (fileTree)
checkType = (fileTree) ->
  TYPE_REGEX_ARRAY.forEach((regex, index) ->
    console.log('COME THIS FAR')
    fileArray = fileTree.filter((file) ->
      if index == 2
        unless TYPE_REGEX_ARRAY[0].test(file)
          sectionsRegex = (new RegExp(file + "\\/[^\\/]+\\."))
          return sectionsRegex.test(fileTree)
      else if index == 3
        midSectionsRegex = (new RegExp(file + "\\/[^\\.]+\z"))
        return midSectionsRegex.test(fileTree)
      else
        return regex.test(file)
    )
    console.log(fileArray.length)
  )

checkType(testFileTree)
console.log('Checked')


  # IS UNIQUE (ARRAY, CLASS)
    # FIX TESTS WITH MISSING INFO
  # HAS PARENT TEST (OBJECT)
    # SAVE ORIGINAL (OBJECT, CLASS)
    # SAVE PLACEHOLDER (OBJECT, CLASS)
    # MAKE THIS POINT TO X (OBJECT, OTHEROBJECTS, CLASS)
    # MAKE X POINT TO THIS (OBJECT, OTHEROBJECTS, CLASS)


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

