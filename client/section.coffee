Template.sectionPage.helpers
  questions: ->
    originals = []
    TestQuestions.find().forEach( (doc) ->
      originals.push(doc.original)
    )
    console.log originals
    return Questions.find({_id: {$in: originals}}, {sort: {question: 1}})

  sectionName: ->
    return TestSections.findOne().filePath