Template.sectionPage.helpers
  questions: ->
    originals = []
    TestQuestions.find({}, {sort: {order: 1}}).forEach( (doc) ->
      console.log "Order: " + doc.order
      originals.push(doc.original)
    )
    console.log originals
    for original, i in originals
      console.log originals[i]
      originals[i] = Questions.findOne(_id: original)
      console.log originals[i]
    return originals

  sectionName: ->
    return TestSections.findOne().filePath