@QuestionResults = new Meteor.Collection(null)

Template.sectionPage.helpers
  questions: ->
    originals = []
    TestQuestions.find({}, {sort: {order: 1}}).forEach( (doc) ->
      console.log "Order: " + doc.order
      originals.push(doc.original)
    )
    for original, i in originals
      QuestionResults.insert(Questions.findOne(_id: original))
    return QuestionResults.find()

  sectionName: ->
    return TestSections.findOne().filePath