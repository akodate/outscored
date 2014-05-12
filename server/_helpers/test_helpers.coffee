@isTest = (file) ->
  return TEST_REGEX.test(file)

@processTest = (file, collection) ->
  if findDocID(collection, {name: file})
    return false
  else
    insertDoc(collection, {name: file})